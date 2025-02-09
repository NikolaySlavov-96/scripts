import fs from 'fs';
import { MongoClient } from 'mongodb';

const logStream = fs.createWriteStream('./logs.txt', { flags: 'a' });

const args = process.argv.slice(2);

const addressArd = args[0];
const dbNameArg = args[1];
const collectionNameArg = args[2];
const dateArd = args[3];

const fetchAndDeleteDocuments = async (dataBase, collectionName, dateString) => {
    const collection = await dataBase.collection(collectionName);

    const date = new Date(dateString);
    const query = { createdAt: { '$lt': date, }, };

    const queryResult = await collection.find(query).toArray();
    const deletedRows = await collection.deleteMany(query);

    return { foundRecordsCount: queryResult.length ?? 0, removedRecordsCount: deletedRows?.deletedCount ?? 0 };
};

const logData = (content) => {
    logStream.write(content);
    logStream.end();
}

const connection = async (address, dbName, collectionName, dateString) => {
    const url = `mongodb://${address}`;
    const client = new MongoClient(url);
    try {
        await client.connect();

        console.log('Connected successfully to MongoDB');

        const dataBase = await client.db(dbName);

        const { foundRecordsCount, removedRecordsCount } = await fetchAndDeleteDocuments(dataBase, collectionName, dateString);

        // Write log
        const reportInitialDate = new Date().toISOString();
        const reportData = `${reportInitialDate} - Found ${foundRecordsCount} records in the ${collectionName} collection; removed ${removedRecordsCount} records base on specified criteria.\n`
        logData(reportData);

        // Listen
        logStream.on('finish', async () => {
            await client.close();
            process.exit(0);
        });

        logStream.on('error', async () => {
            await client.close();
            process.exit(10);
        });
    } catch (err) {
        logData(`${collectionName} -> ${err}\n`)
        logStream.on('finish', async () => {
            await client.close();
            process.exit(1);
        });

        logStream.on('error', async () => {
            await client.close();
            process.exit(10);
        });
    }
}

connection(addressArd, dbNameArg, collectionNameArg, dateArd);