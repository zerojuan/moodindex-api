import { getItem, putTo } from '../db';
import { getUserFiltered } from '../user/get';

export default async function( { userId, mood } ) {
  // check that the user exists?
  const owner = await getUserFiltered( userId );
  if ( !owner ) {
    throw new Error( 'NotFoundError: user not found' );
  }

  // check that the value is between -5 and 5
  if ( mood.value > 5 || mood.value < -5 ) {
    throw new Error( 'BadRequestError: mood out of range' );
  }

  // insert into database
  const newMood = {
    ownerId: userId,
    value: mood.value,
    created: ( new Date() ).toUTCString()
  };
  await putTo( 'Moods', newMood );

  const savedMood = await getItem( 'Moods', { ownerId: newMood.ownerId, created: newMood.created } );
  savedMood.owner = owner;

  return savedMood;
}
