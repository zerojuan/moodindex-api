import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { queryItem } from '../db';


export default async function( { username, password } ) {
  // query db using username
  const user = await queryItem( 'Users', {
    IndexName: 'usernameIndex',
    KeyConditionExpression: 'username = :username',
    ExpressionAttributeValues: {
      ':username': username
    }
  } );

  if ( !user ) {
    return 'NotFoundError: user not found';
  }

  // is password incorrect?
  if ( !( await bcrypt.compare( password, user.password ) ) ) {
    return 'NotFoundError: user not found';
  }

  // create jwt token
  const token = jwt.sign( {
    sub: user.id,
    username: user.username
  }, process.env.JWT_SECRET );

  return token;
}
