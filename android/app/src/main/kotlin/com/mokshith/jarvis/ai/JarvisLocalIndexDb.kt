package com.mokshith.jarvis.ai

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import java.security.MessageDigest

/** Private on-device SQLite/FTS4 memory index. */
class JarvisLocalIndexDb private constructor(context: Context) :
    SQLiteOpenHelper(context.applicationContext, "jarvis_local_index.db", null, 1) {
    companion object {
        @Volatile private var instance: JarvisLocalIndexDb? = null
        fun getInstance(context: Context): JarvisLocalIndexDb =
            instance ?: synchronized(this) { instance ?: JarvisLocalIndexDb(context).also { instance = it } }
        private const val DEDUP_WINDOW_MS = 30L * 60L * 1000L
    }
    override fun onCreate(db: SQLiteDatabase) {
        db.execSQL("""CREATE TABLE memory_entries (
            _id INTEGER PRIMARY KEY AUTOINCREMENT, source TEXT NOT NULL,
            package_name TEXT NOT NULL, content TEXT NOT NULL,
            content_hash TEXT NOT NULL, created_at INTEGER NOT NULL
        )""")
        db.execSQL("CREATE INDEX memory_hash_time ON memory_entries(content_hash, created_at)")
        db.execSQL("CREATE VIRTUAL TABLE memory_fts USING fts4(content, package_name, source, tokenize=unicode61)")
    }
    override fun onConfigure(db: SQLiteDatabase) {
        super.onConfigure(db)
        db.enableWriteAheadLogging()
    }
    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) { }

    @Synchronized
    fun indexDocument(source: String, packageName: String, content: String, timestamp: Long): Long {
        val clean = content.trim().take(20000)
        if (clean.length < 3) return -1L
        val digest = MessageDigest.getInstance("SHA-256").digest(clean.toByteArray(Charsets.UTF_8))
            .joinToString("") { "%02x".format(it) }
        val db = writableDatabase
        db.beginTransaction()
        try {
            val cursor = db.rawQuery("SELECT _id FROM memory_entries WHERE content_hash=? AND created_at>=? LIMIT 1",
                arrayOf(digest, (timestamp - DEDUP_WINDOW_MS).toString()))
            val duplicate = cursor.use { it.moveToFirst() }
            if (duplicate) { db.setTransactionSuccessful(); return -1L }
            val values = ContentValues().apply {
                put("source", source); put("package_name", packageName)
                put("content", clean); put("content_hash", digest); put("created_at", timestamp)
            }
            val id = db.insertOrThrow("memory_entries", null, values)
            val fts = ContentValues().apply {
                put("rowid", id); put("content", clean); put("package_name", packageName); put("source", source)
            }
            db.insertOrThrow("memory_fts", null, fts)
            db.setTransactionSuccessful()
            return id
        } finally { db.endTransaction() }
    }
    @Synchronized
    fun search(query: String, limit: Int = 8): List<Map<String, Any>> {
        val terms = query.lowercase().split(Regex("[^\\p{L}\\p{N}]+"))
            .map { token -> token.filter { it.isLetterOrDigit() } }
            .filter { it.length > 1 }.distinct().take(10)
        if (terms.isEmpty()) return emptyList()
        val safeLimit = limit.coerceIn(1, 30)
        val match = terms.joinToString(" OR ") { "$it*" }
        val sql = """SELECT e._id, e.source, e.package_name, e.content, e.created_at
            FROM memory_fts f JOIN memory_entries e ON e._id=f.rowid
            WHERE memory_fts MATCH ? ORDER BY e.created_at DESC LIMIT ?"""
        return try {
            readableDatabase.rawQuery(sql, arrayOf(match, safeLimit.toString())).use { rowsToMaps(it) }
        } catch (ftsError: Exception) {
            android.util.Log.w("JARVIS_INDEX", "FTS search failed; using LIKE fallback", ftsError)
            try {
                val where = terms.joinToString(" OR ") { "e.content LIKE ?" }
                val args = terms.map { "%$it%" }.toTypedArray() + arrayOf(safeLimit.toString())
                readableDatabase.rawQuery(
                    """SELECT e._id, e.source, e.package_name, e.content, e.created_at
                       FROM memory_entries e WHERE $where ORDER BY e.created_at DESC LIMIT ?""",
                    args
                ).use { rowsToMaps(it) }
            } catch (fallbackError: Exception) {
                android.util.Log.e("JARVIS_INDEX", "LIKE fallback search failed", fallbackError)
                emptyList()
            }
        }
    }

    private fun rowsToMaps(cursor: android.database.Cursor): List<Map<String, Any>> {
        val output = mutableListOf<Map<String, Any>>()
        val now = System.currentTimeMillis()
        while (cursor.moveToNext()) {
            val created = cursor.getLong(4)
            val ageHours = (now - created).coerceAtLeast(0L) / 3600000.0
            output.add(mapOf("id" to cursor.getLong(0), "source" to cursor.getString(1),
                "packageName" to cursor.getString(2), "content" to cursor.getString(3),
                "timestamp" to created, "recencyScore" to (1.0 / (1.0 + ageHours))))
        }
        return output.sortedByDescending { it["recencyScore"] as Double }
    }

    @Synchronized
    fun stats(): Map<String, Any> {
        readableDatabase.rawQuery("SELECT COUNT(*), COALESCE(MAX(created_at), 0) FROM memory_entries", null).use { c ->
            if (c.moveToFirst()) return mapOf("entries" to c.getInt(0), "lastIndexedAt" to c.getLong(1),
                "databaseBytes" to (readableDatabase.path?.let { java.io.File(it).length() } ?: 0L))
        }
        return mapOf("entries" to 0, "lastIndexedAt" to 0L, "databaseBytes" to 0L)
    }
    @Synchronized
    fun clearAll() {
        val db = writableDatabase
        db.beginTransaction()
        try {
            db.delete("memory_fts", null, null)
            db.delete("memory_entries", null, null)
            db.setTransactionSuccessful()
        } finally { db.endTransaction() }
    }
}