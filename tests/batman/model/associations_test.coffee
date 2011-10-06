{TestStorageAdapter} = if typeof require isnt 'undefined' then require './model_helper' else window

QUnit.module "Batman.Model Associations: one-to-one"
  setup: ->
    class @Store extends Batman.Model
      @encode 'id', 'name'

    storeAdapter = new TestStorageAdapter @Store
    storeAdapter.storage =
      'stores1': {name: "One", id: 1}
    @Store.persist storeAdapter

    class @Product extends Batman.Model
      @encode 'id', 'name', 'store_id'

    productAdapter = new TestStorageAdapter @Product
    productAdapter.storage =
      'products1': {name: "One", id: 1, store_id: 1}
      'products2': {name: "Two", id: 2, store_id: 1}
    @Product.persist productAdapter

    @Product.belongsTo 'store', @Store
    @Store.hasOne 'product', @Product

test "belongsTo associations are loaded", ->
  @Product.find 1, (err, product) =>
    store = product.get 'store'
    ok store instanceof @Store
    equal store.id, 1

test "belongsTo associations are saved", 1, ->
  store = new @Store name: 'Zellers'
  product = new @Product name: 'Gizmo'
  product.set 'store', store
  product.save (err, record) ->
    equal record.get('store_id'), store.id

test "hasOne associations are loaded", 2, ->
  @Store.find 1, (err, store) =>
    product = store.get 'product'
    ok product instanceof @Product
    equal product.id, 1

test "hasOne associations are saved", 1, ->
  store = new @Store name: 'Zellers'
  product = new @Product name: 'Gizmo'
  store.set 'product', product
  store.save (err, record) ->
    equal product.get('store_id'), record.id

QUnit.module "hasMany"
  
test "hasMany associations are loaded", ->
  @Store.find 1, (err, store) =>
    products = store.get 'products'
    equal products.length, 2

    ok products[0] instanceof @Product
    ok products[1] instanceof @Product
    equal products[0].id, 1
    equal products[1].id, 2

