import bcrypt from 'bcryptjs'
import jwt from 'jsonwebtoken'
import { queryItem } from '../db'

export default async function ({ username, password }) {
  // query db using username
  try {
    const user = await queryItem('Users', {
      IndexName: 'usernameIndex',
      KeyConditionExpression: 'username = :username',
      ExpressionAttributeValues: {
        ':username': username
      }
    })

    if (!user) {
      throw new Error('NotFoundError: user not found')
    }

    if (user.deleted) {
      throw new Error('NotFoundError: user not found')
    }

    // is password incorrect?
    if (!(await bcrypt.compare(password, user.password))) {
      throw new Error('NotFoundError: user not found')
    }

    // create jwt token
    const token = jwt.sign({
      sub: user.id,
      username: user.username
    }, process.env.JWT_SECRET)

    return token
  } catch (err) {
    console.log( 'This went wrong', err );
    return Promise.reject(err)
  }
}
