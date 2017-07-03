import shortid from 'shortid';

import { putTo, queryItems } from '../db';
import { moodFull } from './get';
import { getUserFiltered } from '../user/get';

export async function getReactList( { reactRef } ) {
  const reacts = await queryItems( 'Reacts', {
    KeyConditionExpression: 'id = :reactRef',
    ExpressionAttributeValues: {
      ':reactRef': reactRef
    }
  } );

  return reacts;
}

export default async function( { principalId, mood, react } ) {
  try {
    // get mood
    const moodFromDb = await moodFull( mood );
    if ( !moodFromDb ) {
      throw new Error( 'NotFoundError: mood not found' );
    }

    // get user
    const user = await getUserFiltered( principalId );
    if ( !user ) {
      throw new Error( 'NotFoundError: user not found' );
    }

    if ( react.value > 5 || react.value < -5 ) {
      throw new Error( 'BadRequestError: value out of range' );
    }

    // does mood have a reactRef?
    if ( !moodFromDb.reactRef ) {
      moodFromDb.reactRef = shortid.generate();
      await putTo( 'Moods', {
        ownerId: moodFromDb.ownerId,
        value: moodFromDb.value,
        reactRef: moodFromDb.reactRef,
        created: moodFromDb.created
      } );
    }

    // insert into react table
    const newReact = {
      id: moodFromDb.reactRef,
      value: react.value,
      ownerId: principalId,
      created: (new Date()).toUTCString()
    }
    await putTo( 'Reacts', newReact );

    return await getReactList( moodFromDb );
  } catch( err ) {
    return Promise.reject( err );
  }
}
