# 🔍 Firestore Debug Guide for User: xq8i7ChN5ycgnSdu7V6PLpHwkmT2

## Quick Access

**Firebase Project:** `microblogging-app-121c9`
**Firebase Console:** https://console.firebase.google.com/project/microblogging-app-121c9/firestore

---

## Data Structure Overview

The NEST app uses two main collections:

### 1. **tbl_users** (Users Collection)
Stores user profile information. Each document is keyed by the user's Firebase Auth UID.

**Expected Fields:**
```
- user_id (String): Firebase Authentication User ID
- username (String): Display name
- profile_picture (String, optional): URL to user's avatar
- bio (String, optional): User bio/description
- followers_count (Number): Count of followers
- following_count (Number): Count of users they follow
```

### 2. **tbl_posts** (Posts Collection)
Stores all posts/content created by users.

**Expected Fields:**
```
- user_id (String): Author's user ID (foreign key to tbl_users)
- content (String): Post text content
- media_url (String): Single media URL (if any)
- images (Array): List of image URLs for carousel
- timestamp (Timestamp): Post creation time
- likes_count (Number): Count of likes
- comments_count (Number): Count of comments
- shares_count (Number): Count of shares
- username (String): Denormalized author username
- user_avatar (String): Denormalized author avatar URL
```

---

## Method 1: Using the Debug Screen in the App (Easiest)

### Setup

1. **Import the debug screen** in your main app or dashboard:

```dart
import 'lib/debug/firestore_debug_screen.dart';
```

2. **Add a debug button** to access the screen (temporary for debugging):

Add this to `dashboard_screen.dart` or any navigation point:

```dart
// Add this floating button to test the debug screen
FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FirestoreDebugScreen()),
    );
  },
  tooltip: 'Debug Firestore',
  child: const Icon(Icons.bug_report),
)
```

3. **Run the app** and tap the debug button to see:
   - ✅ Whether the user document exists
   - 📝 All fields stored for this user
   - 📄 All posts created by this user
   - 📊 Collection statistics
   - 🔍 Sample data from other users for comparison

---

## Method 2: Firebase Console (Web Interface)

### Direct Query Approach

1. **Open Firebase Console:**
   - Go to https://console.firebase.google.com/project/microblogging-app-121c9/firestore
   - Navigate to **Firestore Database**

2. **Query Users Collection:**
   - Click on `tbl_users` collection
   - Use the **Filter** button to add a filter:
     - Field: `__name__` (document ID)
     - Operator: `==`
     - Value: `xq8i7ChN5ycgnSdu7V6PLpHwkmT2`
   - OR directly open the document if it's listed

3. **Query Posts Collection:**
   - Click on `tbl_posts` collection
   - Use the **Filter** button:
     - Field: `user_id`
     - Operator: `==`
     - Value: `xq8i7ChN5ycgnSdu7V6PLpHwkmT2`
   - View all posts by this user

4. **Check Available Collections:**
   - Look at the left sidebar to see all collections
   - Click each collection to view document count and sample data

---

## Method 3: Firebase CLI (Command Line)

If you have Firebase CLI installed (`brew install firebase-tools`):

### View User Document
```bash
firebase firestore:inspect tbl_users/xq8i7ChN5ycgnSdu7V6PLpHwkmT2
```

### Query Posts by User
```bash
# This requires exporting data or using the emulator
# Alternative: use the Firestore REST API

# Get all user data with curl (requires authentication)
curl -X GET \
  'https://firestore.googleapis.com/v1/projects/microblogging-app-121c9/databases/(default)/documents/tbl_users/xq8i7ChN5ycgnSdu7V6PLpHwkmT2' \
  -H 'Authorization: Bearer $(gcloud auth print-access-token)'
```

---

## Method 4: Using Flutter Code Directly (Custom Script)

### Option A: Run Query in App Console

Add this to your `main.dart` temporarily for debugging:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔍 DEBUG: Query user data
  final db = FirebaseFirestore.instance;
  final userId = 'xq8i7ChN5ycgnSdu7V6PLpHwkmT2';
  
  final userDoc = await db.collection('tbl_users').doc(userId).get();
  if (userDoc.exists) {
    print('✅ User found: ${userDoc.data()}');
  } else {
    print('❌ User not found');
  }

  final userPosts = await db
      .collection('tbl_posts')
      .where('user_id', isEqualTo: userId)
      .get();
  print('📄 Posts: ${userPosts.docs.length}');
  for (var post in userPosts.docs) {
    print('  - ${post.id}: ${post.data()}');
  }

  runApp(const NestApp());
}
```

---

## Debugging Checklist

### ✅ Verification Steps

1. **User Document Exists?**
   - [ ] Check if document ID matches exactly: `xq8i7ChN5ycgnSdu7V6PLpHwkmT2`
   - [ ] Look for typos or case sensitivity issues
   - [ ] Verify in Firebase Console

2. **What Fields Are Present?**
   - [ ] `user_id` ✓
   - [ ] `username` ✓
   - [ ] `profile_picture` (optional)
   - [ ] `bio` (optional)
   - [ ] `followers_count` ✓
   - [ ] `following_count` ✓
   - [ ] Any custom fields?

3. **Posts Exist?**
   - [ ] Query `tbl_posts` with `where('user_id', isEqualTo: userId)`
   - [ ] Check post count
   - [ ] View post fields and timestamps

4. **Data Consistency?**
   - [ ] Does post's `user_id` match exactly?
   - [ ] Are denormalized fields (username, avatar) present?
   - [ ] Are timestamps valid?

### 🚨 Common Issues

| Issue | Solution |
|-------|----------|
| User not found | Check exact UID match, verify in Firebase Auth |
| No posts showing | Verify `user_id` field spelling matches exactly |
| Missing fields | Check Firestore rules - may be restricting data |
| Null/undefined values | These are optional fields - use fallbacks in UI |

---

## Expected Output Example

If everything is working, you should see:

```
📋 User Document (tbl_users/xq8i7ChN5ycgnSdu7V6PLpHwkmT2):
  • user_id: xq8i7ChN5ycgnSdu7V6PLpHwkmT2
  • username: john_doe
  • profile_picture: https://...
  • bio: Just a regular user
  • followers_count: 42
  • following_count: 15

📄 Posts (tbl_posts where user_id == xq8i7ChN5ycgnSdu7V6PLpHwkmT2):
  Count: 3

  Post 1 (doc: abc123def456):
    • user_id: xq8i7ChN5ycgnSdu7V6PLpHwkmT2
    • content: Hello NEST world!
    • timestamp: 2026-05-10 14:30:00
    • likes_count: 15
    • comments_count: 3
    
  Post 2 (doc: xyz789uvw321):
    • user_id: xq8i7ChN5ycgnSdu7V6PLpHwkmT2
    • content: This is awesome
    • timestamp: 2026-05-09 10:15:00
    • likes_count: 8
    • comments_count: 1

📊 Collection Stats:
  • tbl_users: 156 documents
  • tbl_posts: 2,847 documents
```

---

## Recommendations

1. **For Development:** Use the debug screen (Method 1) - it's integrated and shows all info
2. **For Quick Checks:** Use Firebase Console (Method 2) - visual and immediate
3. **For Automation:** Use Flutter/Dart code (Method 4) - scriptable and repeatable
4. **For Production:** Remove debug tools and use proper logging/monitoring

---

## Next Steps

After identifying the user data:

1. **Verify Data Integrity:** Ensure all required fields are present
2. **Update App Fetching:** Update `FirestoreService` if needed to fetch additional fields
3. **Fix Data:** If fields are missing, create a migration script to populate them
4. **Update Rules:** Verify Firestore security rules allow proper data access

---

**Need help?** Add more debug info by modifying `firestore_debug_screen.dart` with additional queries!
