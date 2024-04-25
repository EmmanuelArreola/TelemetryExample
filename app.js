const express = require('express');
const ioredis = require('ioredis');
const { log } = require('utils-nxg-cg');

const PORT = process.env.PORT || 3769;
const app = express();
app.use(express.json());

async function setREDISRecord(nameOfRecord, record) {
    const redisClient = new ioredis.Redis();
    redisClient.on('error', (error) => {
        redisClient.disconnect();
        log.warn(`REDIS not available :´${error}`);
        return error;
    });

    try {
        const recordsSaved = await redisClient.set(`${nameOfRecord}`, record);
        await redisClient.quit();
        return recordsSaved;
    } catch (error) {
        return error;
    }
};

app.post('/setCache', async (req, res) => {
    
        try {
            let record = req.body;
            const recordsSaved = await setREDISRecord(record.Project, JSON.stringify(record.Properties));
            //log.debug(`Records saved: ${recordsSaved}`);
            res.status(200).json({ recordsSaved: `${recordsSaved}` });
        } catch (error) {
            log.error(error);
            res.status(500);
        }
});

app.listen(PORT, () => {
    console.log(`Listening for requests on http://localhost:${PORT}`);
});