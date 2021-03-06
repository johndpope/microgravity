_ = require 'underscore'
{ fabricate } = require 'antigravity'
sinon = require 'sinon'
routes = require '../routes'
Profile = require '../../../models/profile'
Backbone = require 'backbone'

describe 'Profile page', ->

  beforeEach ->
    sinon.stub Backbone, 'sync'

  afterEach ->
    Backbone.sync.restore()

  describe '#index', ->

    it 'renders the index page passing on the profile and featured show', ->
      routes.index(
        { profile: new Profile(fabricate 'profile', name: 'Foobarz', owner_type: 'PartnerGallery') }
        { locals: { sd: {} }, render: renderStub = sinon.stub() }
      )
      _.last(Backbone.sync.args)[2].success fabricate('partner', id: 'foobar1', displayable_shows_count: 1)
      _.last(Backbone.sync.args)[2].success { results: [] }
      renderStub.args[0][0].should.equal 'index'
      renderStub.args[0][1].profile.get('name').should.equal 'Foobarz'

  describe '#shows', ->

    it 'renders the shows page passing on the current shows, upcoming shows and past shows', ->
      routes.shows(
        { profile: new Profile(fabricate 'profile', name: 'Foobarz', owner_type: 'PartnerGallery') }
        { render: renderStub = sinon.stub() }
      )
      Backbone.sync.args[0][2].success [
        fabricate('show', status: 'running', name: 'Foo')
        fabricate('show', status: 'upcoming', name: 'Meow')
        fabricate('show', status: 'closed', name: 'Bar')
      ]
      renderStub.args[0][0].should.equal 'shows_page'
      renderStub.args[0][1].profile.get('name').should.equal 'Foobarz'
      renderStub.args[0][1].currentShows[0].get('name').should.equal 'Foo'
      renderStub.args[0][1].currentShows[1].get('name').should.equal 'Meow'
      renderStub.args[0][1].pastShows[0].get('name').should.equal 'Bar'

  describe '#artists', ->

    it 'renders the artists page by passing on the represented/unrep groups', ->
      routes.artists(
        { profile: new Profile(fabricate 'profile', name: 'Foobarz', owner_type: 'PartnerGallery') }
        { render: renderStub = sinon.stub() }
      )
      Backbone.sync.args[0][2].success [
        { artist: fabricate('artist', name: 'Foo'), represented_by: true, image_versions: ['tall'], image_url: '/Foo/bar' }
        { artist: fabricate('artist', name: 'Bar'), represented_by: false }
        { artist: fabricate('artist', name: 'Baz'), represented_by: false, published_artworks_count: 1 }
      ]
      Backbone.sync.args[0][2].success []
      renderStub.args[0][0].should.equal 'artists'
      renderStub.args[0][1].profile.get('name').should.equal 'Foobarz'
      renderStub.args[0][1].represented[0].get('name').should.equal 'Foo'
      renderStub.args[0][1].unrepresented[0].get('name').should.equal 'Baz'

  describe '#contact', ->

    it 'renders the contact page by passing on the partner locations groupped by city', ->
      routes.contact(
        { profile: new Profile(fabricate 'profile', name: 'Foobarz', owner_type: 'PartnerGallery') }
        { render: renderStub = sinon.stub() }
      )
      _.last(Backbone.sync.args)[2].success fabricate('partner', id: 'foobar1', displayable_shows_count: 1)
      _.last(Backbone.sync.args)[2].success [
        fabricate('location', city: 'Zoo York')
        fabricate('location', city: 'Zoo York')
        fabricate('location', city: 'Cincinnati')
      ]
      renderStub.args[0][0].should.equal 'contact'
      renderStub.args[0][1].profile.get('name').should.equal 'Foobarz'
      renderStub.args[0][1].locationGroups['Zoo York'].length.should.equal 2

  describe '#fetchArtworksAndRender', ->

    xit 'renders the partner\'s works based on parameters', ->
      routes.fetchArtworksAndRender(
        {
          label: "Works",
          profile: new Profile(fabricate 'profile', name: 'Foobarz', owner_type: 'PartnerInstitution')
        }
        { render: renderStub = sinon.stub() }
      )
      Backbone.sync.args[0][2].success [
        [fabricate('artwork')]
      ]
      renderStub.args[0][0].should.equal 'contact'
      renderStub.args[0][1].profile.get('name').should.equal 'Foobarz'
      renderStub.args[0][1].locationGroups['Zoo York'].length.should.equal 2

