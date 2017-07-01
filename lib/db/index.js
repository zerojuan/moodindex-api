// Accesses dynamodb
import AWS from 'aws-sdk';

let dbPrefix = process.env.ENVIRONMENT;
// load local db if in dev mode
if ( process.env.ENVIRONMENT === 'local' ) {
  dbPrefix = '';
  AWS.config.update({
    endpoint: 'http://localhost:8000',
    region: 'us-east-2'
  });
}

const db = new AWS.DynamoDB.DocumentClient();

export const client = db;

export function getUserPermission( { userType, id } ) {
  const params = {
    TableName: `${dbPrefix}AccessPolicies`
  };

  if ( id === '*' ) {
    // query all
    params.KeyConditionExpression = 'userType = :userType';
    params.ExpressionAttributeValues = {
      ':userType': userType
    };
  } else {
    // query specific
    params.KeyConditionExpression = 'userType = :userType AND id = :id';
    params.ExpressionAttributeValues = {
      ':userType': userType,
      ':id': id
    };
  }

  return db.query( params ).promise().then( ( res ) => {
    return res.Items;
  });
}

export function getUserPermissions( roles ) {
  // if roles is an asterisk use a different query
  return Promise.all(
    roles.map( getUserPermission )
  ).then( ( res ) => {
    // flatten the array results
    return [].concat.apply([], res);
  } );
}

export function getItem( table, key ) {
  const params = {
    TableName: `${dbPrefix}${table}`,
    Key: key
  };

  return db.get( params ).promise()
    .then( ( data ) => data.Item );
}

export function putTo( table, item ) {
  const params = {
    TableName: `${dbPrefix}${table}`,
    Item: item
  };

  return db.query( params ).promise();
}
