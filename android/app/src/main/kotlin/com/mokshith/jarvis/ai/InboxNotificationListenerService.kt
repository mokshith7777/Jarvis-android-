package com.mokshith.jarvis.ai
import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import java.util.concurrent.CopyOnWriteArrayList
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/**
 * Captures email and SMS notifications from Gmail, Outlook, Yahoo, and native messengers
 * so J.A.R.V.I.S. can triage and read inboxes in real-time.
 */
class InboxNotificationListenerService : NotificationListenerService() {
    private val indexExecutor: ExecutorService = Executors.newSingleThreadExecutor()

    companion object {
        @Volatile
        var isConnected: Boolean = false
            private set

        val capturedEmailNotifications = CopyOnWriteArrayList<Map<String, Any>>()
        val capturedSmsNotifications = CopyOnWriteArrayList<Map<String, Any>>()

        private const val MAX_SAVED = 40
        private val emailMutationLock = Any()
        private val smsMutationLock = Any()

        fun getRecentEmails(): List<Map<String, Any>> = capturedEmailNotifications.toList()
        fun getRecentSms(): List<Map<String, Any>> = capturedSmsNotifications.toList()
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        isConnected = true
        try {
            val active = activeNotifications
            if (active != null) {
                for (sbn in active) {
                    processNotification(sbn)
                }
            }
        } catch (_: Exception) {}
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        isConnected = false
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        if (sbn == null) return
        processNotification(sbn)
    }

    private fun processNotification(sbn: StatusBarNotification) {
        val pkg = sbn.packageName ?: ""
        val extras = sbn.notification?.extras ?: return

        val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString() ?: ""
        val bigText = extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString()
        val regularText = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString()
        val text = bigText?.takeIf { it.isNotBlank() } ?: regularText.orEmpty()
        val subText = extras.getCharSequence(Notification.EXTRA_SUB_TEXT)?.toString() ?: ""
        val postTime = sbn.postTime

        if (title.isBlank() && text.isBlank()) return

        val indexEnabled = getSharedPreferences("jarvis_local_index", MODE_PRIVATE)
            .getBoolean("social_indexing_enabled", false)
        val indexPackages = setOf(
            "com.instagram.android", "com.google.android.youtube", "com.twitter.android",
            "com.whatsapp", "com.linkedin.android", "org.telegram.messenger", "com.android.chrome"
        )
        if (indexEnabled && pkg in indexPackages) {
            val content = listOf(title, text, subText).filter { it.isNotBlank() }.joinToString("\n")
            try {
                indexExecutor.execute {
                    try {
                        JarvisLocalIndexDb.getInstance(applicationContext)
                            .indexDocument("notification", pkg, content, postTime)
                    } catch (error: Exception) {
                        android.util.Log.w("JARVIS_INDEX", "Notification indexing failed", error)
                    }
                }
            } catch (error: Exception) {
                android.util.Log.w("JARVIS_INDEX", "Notification index executor unavailable", error)
            }
        }

        val item = mapOf(
            "package" to pkg,
            "title" to title,
            "text" to text,
            "subText" to subText,
            "timestamp" to postTime,
            "id" to sbn.id.toString()
        )

        val isEmail = pkg.contains("mail", ignoreCase = true) ||
                pkg.contains("outlook", ignoreCase = true) ||
                pkg == "com.google.android.gm" ||
                pkg == "com.microsoft.office.outlook" ||
                pkg == "com.yahoo.mobile.client.android.mail" ||
                pkg == "com.samsung.android.email.provider"

        val isSms = pkg.contains("messaging", ignoreCase = true) ||
                pkg.contains("mms", ignoreCase = true) ||
                pkg == "com.google.android.apps.messaging" ||
                pkg == "com.samsung.android.messaging"

        if (isEmail) {
            synchronized(emailMutationLock) {
                capturedEmailNotifications.removeIf { it["title"] == title && it["text"] == text }
                capturedEmailNotifications.add(0, item)
                while (capturedEmailNotifications.size > MAX_SAVED) {
                    capturedEmailNotifications.removeAt(capturedEmailNotifications.size - 1)
                }
            }
        } else if (isSms) {
            synchronized(smsMutationLock) {
                capturedSmsNotifications.removeIf { it["title"] == title && it["text"] == text }
                capturedSmsNotifications.add(0, item)
                while (capturedSmsNotifications.size > MAX_SAVED) {
                    capturedSmsNotifications.removeAt(capturedSmsNotifications.size - 1)
                }
            }
        }
    }

    override fun onDestroy() {
        indexExecutor.shutdownNow()
        super.onDestroy()
    }
}
