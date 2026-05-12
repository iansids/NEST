# ⚡ Quick Reference: Query User Data

## 🎯 Goal
Find all data for user ID: `xq8i7ChN5ycgnSdu7V6PLpHwkmT2` across Firestore collections

---

## 🚀 Fastest Method: Firebase Console (2 minutes)

### Step 1: Open Firebase Console
https://console.firebase.google.com/project/microblogging-app-121c9/firestore

### Step 2: Query User Document
1. Click **`tbl_users`** collection in left sidebar
2. Look for document ID: `xq8i7ChN5ycgnSdu7V6PLpHwkmT2`
3. Click it to view all fields:
   ```
   ✓ user_id
   ✓ username
   ✓ profile_picture (if exists)
   ✓ bio (if exists)
   ✓ followers_count
   ✓ following_count
   ```

### Step 3: Query User's Posts
1. Click **`tbl_posts`** collection in left sidebar
2. Click **Filter** button
3. Add filter:
   - **Field:** `user_id`
   - **Operator:** `==`
   - **Value:** `xq8i7ChN5ycgnSdu7V6PLpHwkmT2`
4. Click **Apply**
5. See all posts with fields:
   ```
   ✓ content
   ✓ timestamp
   ✓ likes_count
   ✓ comments_count
   ✓ images/media_url
   ```

---

## 🛠️ Debug in App (3 minutes setup)

### Quick Setup:

1. **Open** `lib/features/dashboard/screens/dashboard_screen.dart`

2. **Add this import** at the top:
```dart
import 'package:nest/debug/firestore_debug_screen.dart';
```

3. **Add this to the Scaffold** (find the existing `floatingActionButton` or add new one):
```dart
floatingActionButton: FloatingActionButton(
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

4. **Run app:**
```bash
flutter run
```

5. **Tap the 🐛 bug icon** to see complete debug report

---

## 💻 Code Snippet: Manual Query

Add this to `main.dart` temporarily:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final db = FirebaseFirestore.instance;
  final userId = 'xq8i7ChN5ycgnSdu7V6PLpHwkmT2';

  // 1. Get user
  print('\\n=== USER DATA ===');
  final userDoc = await db.collection('tbl_users').doc(userId).get();
  if (userDoc.exists) {
    print('✅ User found:');
    userDoc.data()?.forEach((k, v) => print('  $k: $v'));
  } else {
    print('❌ User not found');
  }

  // 2. Get posts
  print('\\n=== USER POSTS ===');
  final posts = await db
      .collection('tbl_posts')
      .where('user_id', isEqualTo: userId)
      .orderBy('timestamp', descending: true)
      .get();
  
  print('Found ${posts.docs.length} posts:');
  for (var post in posts.docs) {
    print('\\n  Post ID: ${post.id}');
    post.data().forEach((k, v) => print('    $k: $v'));
  }

  runApp(const NestApp());
}
```

---

## 📊 Expected Results

### User Document Should Show:
```json
{
  "user_id": "xq8i7ChN5ycgnSdu7V6PLpHwkmT2",
  "username": "[display name]",
  "profile_picture": "https://...",
  "bio": "[user bio]",
  "followers_count": [number],
  "following_count": [number]
}
```

### Posts Should Show:
```json
[
  {
    "user_id": "xq8i7ChN5ycgnSdu7V6PLpHwkmT2",
    "content": "Post text here",
    "timestamp": "[Date]",
    "likes_count": 0,
    "comments_count": 0,
    "images": ["url1", "url2"],
    "media_url": "url"
  }
]
```

---

## ❓ Quick Q&A

| Q | A |
|---|---|
| Where do I see the user info? | Firebase Console → `tbl_users` collection → Find document ID |
| How do I find posts? | Firebase Console → `tbl_posts` → Filter by `user_id` |
| Can I query from the app? | Yes, use the debug screen (Method 2) |
| What if user doesn't exist? | Check ID spelling/case, might not have signed up yet |
| Are the collections named correctly? | Yes, both are prefixed with `tbl_`: `tbl_users` and `tbl_posts` |

---

## 📚 Full Documentation

For complete details, see:
- [FIRESTORE_STRUCTURE.md](./FIRESTORE_STRUCTURE.md) — Full schema & queries
- [FIRESTORE_DEBUG_GUIDE.md](./FIRESTORE_DEBUG_GUIDE.md) — Detailed debug guide

---

**Firebase Project:** `microblogging-app-121c9`
**Console:** https://console.firebase.google.com/project/microblogging-app-121c9/firestore
