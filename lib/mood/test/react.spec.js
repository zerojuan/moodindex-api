import React from '../react';

describe( 'React', () => {
  let fixture = {};
  beforeEach( () => {
    fixture = {
      principalId: '2',
      mood: {
        ownerId: '1',
        value: 5,
        created: '2016-11-10T17:21:07.5272333Z',
        reactRef: '1'
      },
      react: {
        value: 5
      }
    }
  } );
  it( '- Should NotFound on non-existent mood', async () => {
    fixture.mood.ownerId = '0';

    await expect( React( fixture ) ).rejects.toMatchObject( {
      message: 'NotFoundError: mood not found'
    } );
  } );

  it( '- Should BadRequest when value is too large', async () => {
    fixture.react.value = 100;

    await expect( React( fixture ) ).rejects.toMatchObject( {
      message: 'BadRequestError: value out of range'
    } );
  } );

  it( '- Should BadRequest when value is too small', async () => {
    fixture.react.value = -100;

    await expect( React( fixture ) ).rejects.toMatchObject( {
      message: 'BadRequestError: value out of range'
    } );
  } );

  it( '- Should Respond with the list of reacts', async () => {
    const result = await React( fixture );

    expect( result ).toHaveLength( 2 );
    result.forEach( ( react ) => {
      expect( react.id ).toBe( fixture.mood.reactRef );
    } );
  } );

} );
