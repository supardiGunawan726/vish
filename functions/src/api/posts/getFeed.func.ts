import { getFirestore } from "firebase-admin/firestore";
import * as functions from "firebase-functions";

export default functions.https.onCall(async function (data, context) {
  const postsDocs = await getFirestore().collection("posts").get();
  console.log(postsDocs.docs.length);
  const posts = [];

  for (const postDoc of postsDocs.docs) {
    posts.push(postDoc.data());
  }

  return {
    posts,
  };
});
