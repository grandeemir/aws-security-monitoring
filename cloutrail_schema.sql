CREATE EXTERNAL TABLE security_monitoring_db.cloudtrail_logs (
    eventVersion STRING,
    userIdentity STRUCT<
        type: STRING,
        principalId: STRING,
        arn: STRING,
        accountId: STRING,
        invokedBy: STRING,
        accessKeyId: STRING,
        userName: STRING,
        sessionContext: STRUCT<
            attributes: STRUCT<
                mfaAuthenticated: STRING,
                creationDate: STRING
            >,
            sessionIssuer: STRUCT<
                type: STRING,
                principalId: STRING,
                arn: STRING,
                accountId: STRING,
                userName: STRING
            >
        >
    >,
    eventTime STRING,
    eventSource STRING,
    eventName STRING,
    awsRegion STRING,
    sourceIpAddress STRING,
    userAgent STRING,
    errorCode STRING,
    errorMessage STRING,
    requestParameters STRING,
    responseElements STRING,
    additionalEventData STRING,
    requestId STRING,
    eventId STRING,
    resources ARRAY<STRUCT<
        ARN: STRING,
        accountId: STRING,
        type: STRING
    >>,
    eventType STRING,
    apiVersion STRING,
    readOnly STRING,
    recipientAccountId String,
    serviceEventDetails STRING,
    sharedEventID STRING,
    vpcEndpointId STRING
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
STORED AS INPUTFORMAT 'org.apache.hadoop.mapred.TextInputFormat'
OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION 's3://security-monitoring-XXXXXXXXXX/cloudtrail-logs/AWSLogs/XXXXXXXXXX/CloudTrail/';




DROP TABLE IF EXISTS security_monitoring_db.cloudtrail_logs;



SELECT eventTime, eventName, awsRegion, sourceIpAddress 
FROM security_monitoring_db.cloudtrail_logs 
LIMIT 10;


SELECT 
    eventTime, 
    userIdentity.userName as user_name, 
    eventName, 
    awsRegion, 
    sourceIpAddress,
    errorCode,
    errorMessage
FROM security_monitoring_db.cloudtrail_logs
WHERE userIdentity.userName = '3tierapp_user'
ORDER BY eventTime DESC
LIMIT 10;