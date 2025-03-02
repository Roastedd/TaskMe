# Setting Up Google OAuth in Supabase for TaskMe

This guide will walk you through the process of setting up Google OAuth authentication for your TaskMe app using Supabase.

## 1. Configure Supabase Authentication

1. Go to your Supabase dashboard: https://app.supabase.io
2. Select your TaskMe project
3. Navigate to **Authentication** > **Providers** in the sidebar
4. Find the **Google** provider and toggle it to **Enabled**

## 2. Configure Redirect URLs

In the Google provider settings, add the following redirect URLs:
- `io.supabase.taskme://login-callback` (for iOS)
- `https://hkjagszkbwvvwzzvlvlp.supabase.co/auth/v1/callback` (for web)

## 3. Set Up Google Cloud OAuth Credentials

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select your existing project
3. Navigate to **APIs & Services** > **Credentials**
4. Click **Create Credentials** > **OAuth client ID**
5. Select **Web application** as the application type
6. Add a name for your OAuth client (e.g., "TaskMe Auth")
7. Under **Authorized redirect URIs**, add:
   - `https://hkjagszkbwvvwzzvlvlp.supabase.co/auth/v1/callback`
8. Click **Create**
9. Copy the **Client ID** and **Client Secret**

## 4. Add Google OAuth Credentials to Supabase

1. Return to your Supabase dashboard
2. In the Google provider settings, paste the **Client ID** and **Client Secret** from Google Cloud Console
3. Click **Save**

## 5. Configure iOS App for Deep Links

The iOS app should already be configured with the correct URL scheme in the `Info.plist` file:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>io.supabase.taskme</string>
    </array>
  </dict>
</array>
```

## 6. Configure Android App for Deep Links

The Android app should already be configured with the correct intent filter in the `AndroidManifest.xml` file:

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="io.supabase.taskme" />
</intent-filter>
```

## 7. Testing the Authentication Flow

1. Run the TaskMe app on your device
2. Tap the "Continue with Google" button
3. You should be redirected to the Google sign-in page
4. After signing in, you should be redirected back to the app and logged in successfully

## Troubleshooting

If you encounter issues with the authentication flow:

1. **Check Redirect URLs**: Ensure the redirect URLs are correctly configured in both Supabase and Google Cloud Console.
2. **Verify OAuth Credentials**: Make sure the Client ID and Client Secret are correctly copied from Google Cloud Console to Supabase.
3. **Check App Configuration**: Verify that the URL schemes are correctly set up in the iOS and Android app configurations.
4. **Enable Required APIs**: In Google Cloud Console, make sure the Google+ API or Google People API is enabled for your project.
5. **Check Logs**: Look at the logs in the app to see if there are any specific error messages that can help identify the issue.

## Additional Resources

- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- [Google OAuth Documentation](https://developers.google.com/identity/protocols/oauth2)
- [Flutter Deep Links Documentation](https://docs.flutter.dev/development/ui/navigation/deep-linking) 