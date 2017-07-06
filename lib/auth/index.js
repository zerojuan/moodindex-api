import jwt from 'jsonwebtoken';
import arnParser from 'aws-arn-parser';
import { getItem, getUserPermissions } from '../db';


export function generatePolicy( principalId, methodArn, permissions ) {
  const authResponse = {};
  authResponse.principalId = 'user';

  const arn = arnParser( methodArn );
  const apiPath = arn.relativeId.split( '/' );

  const policyDocument = {};
  policyDocument.Version = '2012-10-17';
  policyDocument.Statement = permissions.map( ( permission ) => {
    return {
      Action: [ 'execute-api:Invoke' ],
      Effect: permission.effect,
    //   Resource: [ `arn:aws:execute-api:${arn.region}:${arn.namespace}:${apiPath[ 0 ]}/${apiPath[ 1 ]}/${permission.route}` ]
    Resource: [ `arn:aws:execute-api:${arn.region}:${arn.namespace}:${apiPath[ 0 ]}/*/*` ]
    };
  } );
  
  console.log( policyDocument.Statement );

  authResponse.policyDocument = policyDocument;

  // NOTE: you can add additional fields in the context object
  authResponse.context = {};
  authResponse.context.userId = principalId;
  authResponse.context.message = 'Authenticate Success';

  return authResponse;
}

export function decodeToken( token ) {
  return jwt.decode( token, process.env.JWT_SECRET );
}

export default async function( { authorizationToken, methodArn } ) {
  try {
    // Decode JWT token
    const decodedToken = decodeToken( authorizationToken );

    // Load User from database
    const user = await getItem( 'Users', {
      id: decodedToken.sub
    } );

    if ( !user ) {
      throw new Error( 'NotFoundError: user not found' );
    }

    if ( user.deleted ) {
      throw new Error( 'NotFoundError: user not found' );
    }

    // Load permissions
    const permissions = await getUserPermissions( user.roles.map( ( role ) => {
      const splitRole = role.split( ':' );
      return {
        userType: splitRole[ 0 ],
        id: splitRole[ 1 ]
      };
    } ) );

    const generatedPolicy = generatePolicy( decodedToken.sub, methodArn, permissions );
    console.log( 'Generated Policy', generatedPolicy );
    return generatedPolicy;
  } catch( err ) {
    return Promise.reject( err );
  }

}
