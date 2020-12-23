'use strict';

const accountSid = process.env.TWILIO_ACCOUNT_SID;
const authToken = process.env.TWILIO_AUTH_TOKEN;
const client = require('twilio')(accountSid, authToken);

client.incomingPhoneNumbers.each(item => {
    console.log(`Found phone number (${item.phoneNumber}) with sid: ${item.sid}`);
});
