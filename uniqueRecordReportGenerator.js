import fs from 'fs';
import fsAsync from 'fs/promises';
import { MongoClient } from 'mongodb';

import config from './config.json' assert { type: 'json' };

const logStream = fs.createWriteStream('./logs.txt', { flags: 'a' });

const queryCollection = config.queryCollection;

// const env = process.env.NAME;
const args = process.argv.slice(2);

const addressArg = args[0];
const dbNameArg = args[1];
const collectionNameArg = args[2];
const fieldArg = args[3];


const fetchUniqueParams = async (dataBase, collectionName, field) => {
    const temporaryStore = [];
    const dateString = [];

    const collection = await dataBase.collection(collectionName);

    const selectedCollection = queryCollection[field];
    const result = await collection.find(selectedCollection).toArray();

    result.map(el => {
        const param = el[field];
        if (!temporaryStore.includes(param)) {
            temporaryStore.push(param);
        };

        const timestampFiled = el[config.timestampField];
        if (!!timestampFiled) {
            dateString.push(el?.createdAt);
        }
    });
    return { uniqueData: temporaryStore, allDates: dateString };
}

const findDateRange = async (date) => {
    const dates = date.map(dateString => new Date(dateString));
    const { earliestDate, latestDate } = dates.reduce((acc, currentDate) => {
        return {
            earliestDate: currentDate < acc.earliestDate ? currentDate : acc.earliestDate,
            latestDate: currentDate > acc.latestDate ? currentDate : acc.latestDate
        };
    }, { earliestDate: dates[0], latestDate: dates[0] });

    return { minDate: earliestDate, maxDate: latestDate };
}

const generateReportDateRange = (date) => {
    const {
        minDate,
        maxDate = new Date(),
    } = date;

    // const smallestDate = dates.reduce((minDate, currentDate) => {
    //     return currentDate < minDate ? currentDate : minDate;
    // });

    const minD = minDate ? new Date(minDate).toISOString() : '∞';
    const maxD = (maxDate ? new Date(maxDate) : new Date()).toISOString();

    const reportDateRange = `${minD}-*-${maxD}`;
    return reportDateRange
};

const generateReport = async (data, collectionName, date) => {
    const filePath = `./Reports/${collectionName}-${date}.txt`;
    let reportData = '';
    data.length && data.map((r, index) => {
        reportData += `${index} -> ${r} \n`
    })
    await fsAsync.writeFile(filePath, reportData, 'utf8');
};

const logData = (content) => {
    logStream.write(content);
    logStream.end();
}

const connection = async (address, dbName, collectionName, field) => {
    const url = `mongodb://${address}`;
    const client = new MongoClient(url);
    try {
        await client.connect();

        const dataBase = await client.db(dbName);

        // Get Unique Data
        const result = await fetchUniqueParams(dataBase, collectionName, field);

        // Generate Date Time
        const dates = !!result?.allDates?.length ? await findDateRange(result.allDates) : {};
        const reportDateRange = generateReportDateRange(dates);

        // Write Report in System
        const hasValidReportData = result?.uniqueData && result.uniqueData[0] !== 'undefined';
        const fieldCollectionKey = field + ' ' + collectionName;
        hasValidReportData && await generateReport(result?.uniqueData, fieldCollectionKey, reportDateRange);

        // Write log
        const reportInitialDate = new Date().toISOString();
        const reportStatusMessage = hasValidReportData ? '- Success create report for' : '- No data to record from'
        const reportData = hasValidReportData ?
            `${reportInitialDate} ${reportStatusMessage} ${fieldCollectionKey}\n`
            :
            `${reportInitialDate} ${reportStatusMessage} ${fieldCollectionKey}\n`
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

connection(addressArg, dbNameArg, collectionNameArg, fieldArg);