// posts.js

import clientPromise from "../../lib/mongodb_client";

export default async function handler(req, res) {
  const client = await clientPromise;
  const db = client.db("sufriends");
  switch (req.method) {
    case "POST":
      let bodyObject = JSON.parse(req.body);
      let proposal = await db.collection("proposals").insertOne(bodyObject);
      res.json(proposal.ops[0]);
      break;
    case "GET":
      const all = await db.collection("test").find({}).toArray();
      res.json({ status: 200, data: all });
      break;
  }
}