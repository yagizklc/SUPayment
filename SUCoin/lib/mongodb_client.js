import { MongoClient } from 'mongodb'
require("dotenv").config({ path: ".env" });

const url = process.env.MONGODB_URL
const db_name = process.env.DB_NAME
const options = {
    useUnifiedTopology: true,
    useNewUrlParser: true,
}


if (!process.env.MONGODB_URL) {
    throw new Error('Add Mongo URL to .env.local')
}

try {
    var client = new MongoClient(url, options)
    var clientPromise = client.connect()
} catch (error) {
    console.log("Could not connect to mongodb client.")
}


export default clientPromise