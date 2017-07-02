import GetMood from '../get';

describe( 'GetMood', () => {
  it( '- Should return 404 if not found', async () => {
    const fixture = {
      ownerId: '99',
      created: '2016-11-11T17:21:07.5272333Z'
    };

    await expect( GetMood( fixture ) ).rejects.toMatchObject( {
      message: 'NotFoundError: mood not found'
    } );
  } );
  it( '- Should return mood at specified id and time', async () => {
    const fixture = {
      ownerId: '1',
      created: '2016-11-11T17:21:07.5272333Z'
    };

    const result = await GetMood( fixture );
    expect( result ).toHaveProperty( 'ownerId', fixture.ownerId );
    expect( result ).toHaveProperty( 'created', fixture.created );
    expect( result ).toHaveProperty( 'value' );
    expect( result ).toHaveProperty( 'owner.name' );
    expect( result ).toHaveProperty( 'owner.username' );
    expect( result ).not.toHaveProperty( 'owner.password' );
  } );
} );
