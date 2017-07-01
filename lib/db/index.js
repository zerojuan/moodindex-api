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
const dynamoDb = new AWS.DynamoDB();

export function softCount( table ) {
  const params = {
    TableName: `${dbPrefix}${table}`
  };

  return dynamoDb.describeTable( params ).promise()
    .then( ( data ) => {
      return data.Table.ItemCount;
    } );
}

export function scan( table, scanParams ) {
  const params = Object.assign( {}, scanParams, {
    TableName: `${dbPrefix}${table}`
  } );

  return db.scan( params ).promise();
}

export function query( table, queryParams ) {
  // append prefix to table name
  const params = Object.assign( {}, queryParams, {
    TableName: `${dbPrefix}${table}`
  } );

  return db.query( params ).promise();
}

export function queryItem( table, queryParams ) {
  return query( table, queryParams ).then( ( data ) => {
    if ( data.length === 0 ) {
      return null;
    }

    if ( data.length > 1 ) {
      throw new Error( `InternalServerError: Expected 1 but got ${data.length}` );
    }

    return data.Items[ 0 ];
  } );
}

export function queryItems( table, queryParams ) {
  return query( table, queryParams ).then( ( data ) => {
    return data.Items;
  } );
}

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

  return queryItems( 'AccessPolicies', params );
}

export function getUserPermissions( roles ) {
  // if roles is an asterisk use a different query
  return Promise.all(
    roles.map( getUserPermission )
  ).then( ( data ) => {
    // flatten the array results
    // [ [ a, b ], [ c ], [ d, e ] ] => [ a, b, c, d, e ]
    return [].concat.apply([], data);
  } );
}

export function batchGet( table, items, attributes ) {
  const tableName = `${dbPrefix}${table}`;
  const params = {
    RequestItems: {}
  };

  params.RequestItems[ tableName ] = {
    Keys: items,
    AttributesToGet: attributes
  };

  return db.batchGet( params ).promise()
    .then( ( data ) => {
      return data.Responses[ tableName ];
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
