import { getItem } from '../db';

// Returns the username and name of this user
export function getUserFiltered( id ) {
  return getItem( 'Users', { id: id } )
    .then( ( user ) => {
      if ( !user ) {
        return null;
      }
      return {
        id: id,
        name: user.name,
        username: user.username
      };
    })
}
