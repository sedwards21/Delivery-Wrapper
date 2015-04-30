//
//  Delivery.swift
//  Delivery-Swift
//
//  Created by Shane Edwards on 4/24/15.
//
//

import Foundation

class Delivery {
    
    let clientId : String
    let apiKey : String
    let environment : String
    let urls : Dictionary<String,String>
    
    init(apiKey: String, environment: String){
        self.apiKey = apiKey
        self.environment = environment
        self.clientId = apiKey
        
        if environment == "development" {
            urls = [
                "customer" : "https://api.delivery.com/customer",
                "merchant" : "https://api.delivery.com/merchant",
                "promotion": "https://api.delivery.com/api/customer.promo/deal",
                "aCustomer": "https://api.delivery.com/api/customer",
                "aMerchant": "https://api.delivery.com/api/merchant"
            ]
        } else {
            urls = [
                "customer" : "https://sandbox.delivery.com/customer",
                "merchant" : "https://sandbox.delivery.com/merchant",
                "promotion": "https://sandbox.delivery.com/api/customer.promo/deal"
                
            ]
        }
    }
    
    func makeApiRequest( apiGroup: String, endpointPath: String, pathTpl: String, method: String, userAuth: Bool, parameters: Dictionary<String,String>?, postFields : [String]? ) {
        //used to set up path
        
        var uri = endpointPath
        var postData: Dictionary<String, AnyObject> = [:]
        var headerFields: Dictionary<String, String> = [:]
        
        for path in pathTpl.componentsSeparatedByString("/"){
            //if there is a colon provide the value, if no colon just use the word itself
            if path.hasPrefix(":") {
                var param = path.substringFromIndex(advance(path.startIndex, 1))
                uri += "/\(parameters[param]!)"
            }else if(!path.isEmpty){
                uri += "/\(path)"
            }
        }
        
        //initialize post fields if needed
        if(postFields != nil){
            for field in postFields!{
                if(parameters[field] != nil){
                    postData[field] = parameters[field]
                }
            }
        }
        
        if userAuth {
            //TODO: Deal with user authentication
        }else{
            uri += "?client_id=\(clientId)"
        }
        
        var encodedUrl : NSString = "\(urls[apiGroup]!)\(uri)"
        encodedUrl = encodedUrl.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        
        if method == "post" {
            
        } else if method == "put" {
            
        } else if method == "delete" {
            
        } else {
            
        }
    }
    
    func get_guest_token(){
        //GET /customer/auth/guest
        
        makeApiRequest("customer", endpointPath: "auth/guest", pathTpl: "", method: "get", userAuth: false, parameters: nil, postFields: nil)
    }
    
    func get_saved_locations(){
        // GET/customer/location/
        
        makeApiRequest("customer", endpointPath: "location", pathTpl: "", method: "get", userAuth: true, parameters: nil, postFields: nil)
    }
    
    func get_user_cart(params: Dictionary<String, String>){
        // GET /customer/cart/{merchant_id}
        // req order_type
        //opt = order_time, client_id
        //req for delivery= zip, city, state, latitude, longitude
        
        makeApiRequest("customer", endpointPath: "cart", pathTpl: "/:merchant_id", method: "get", userAuth: true, parameters: params, postFields: nil)

    }
    
    func get_guest_cart(){
        
    }
    
    func get_user_order(params: Dictionary<String, String>){
       // GET /customer/orders/recent/{order_id}
        // order_id
        
        makeApiRequest("customer", endpointPath: "/orders/recent", pathTpl: "/:order_id", method: "get", userAuth: true, parameters: params, postFields: nil)
    }
    
    //order history
    func get_user_history(params: Dictionary<String, String>){
       // GET /customer/orders/recent
        
        makeApiRequest("customer", endpointPath: "/orders/recent", pathTpl: "", method: "get", userAuth: true, parameters: nil, postFields: nil)
    }
    
    func get_customer_info(params: Dictionary<String,String>){
        // GET /customer/account
        
        makeApiRequest("customer", endpointPath: "/account", pathTpl: "", method: "get", userAuth: true, parameters: params, postFields: nil)
    }
    
    func get_payments(params: Dictionary<String, String>){
        // GET /customer/cart/{merchant_id}/checkout
        //req = order_time, order_type
        
        makeApiRequest("customer", endpointPath: "/cart", pathTpl: "/:merchant_id/checkout", method: "get", userAuth: true, parameters: params, postFields: nil)
    }
    
    func get_fav_orders(){
        // GET /api/customer/orders/favorite
        //TODO: Create endpoint url
        makeApiRequest("customer", endpointPath: "api/customer/orders/favorite", pathTpl: "", method: "get", userAuth: true, parameters: nil, postFields: nil)
    }
    
    func get_cc_request(){
        // GET /customer/cc
        //include_expired whether or not to include expired cards
        
        makeApiRequest("customer", endpointPath: "/cc", pathTpl: "", method: "get", userAuth: true, parameters: nil, postFields: nil)
    }
    
    func get_fav_merch(){
        // GET /api/merchant/favorite
    }
    
    func get_merch_info(){
        
    }
    
    func get_merch_menu(){
        
    }
    
    func find_merch(){
        
    }
    
    func get_promotion(){
        
    }
    
    func delete_location(){
        // DELETE /customer/location/{location_id}
        
        makeApiRequest("customer", endpointPath: "/location", pathTpl: "", method: "delete", userAuth: true, parameters: nil , postFields: nil )
    }
    
    func delete_fav_orders(){
        // DELETE /api/customer/orders/favorite/{order_id}
    }
    
    func delete_fav_merch(){
        // DELETE /api/merchant/favorite/{merchant_id}
    }
    
    func add_cc(){
        
    }
    
    func add_fav_order(params: Dictionary<String, String> ){
        // POST /api/customer/orders/favorite/{order_id}
        //order_name
        
        makeApiRequest("aCustomer", endpointPath: "/orders/favorite", pathTpl: "/:merchant_id", method: "post", userAuth: true, parameters: params, postFields: ["order_name"])
    }
    
    func add_fav_merch(){
        // POST /api/merchant/favorite/{merchant_id}
    }
    
    func login_cred(){
        
    }
    
    func add_to_user_cart(params: Dictionary<String,String> ){
        // POST /customer/cart/{merchant_id}
        var postFields = ["order_type", "item"]
        makeApiRequest("customer", endpointPath: "cart", pathTpl: "/:merchant_id", method: "post", userAuth: true, parameters: params, postFields: postFields)
    }
    
    func add_to_guest_cart(params: Dictionary<String, String>){
        // POST /customer/cart/{merchant_id}
        
        makeApiRequest("customer", endpointPath: <#String#>, pathTpl: <#String#>, method: <#String#>, userAuth: false, parameters: params, postFields: <#[String]?#>)
    }
    
    func create_location(params : Dictionary<String, String>){
        //req street, city, state abbr,zip, phone
        //optional unit number, company, street
        var required = ["street", "city", "state", "zip", "phone"]
        var postFields: [String] = [
            "street", "city", "state", "zip_code", "phone", "unit_number", "company", "street"
        ]
        
        makeApiRequest("customer", endpointPath: "/location", pathTpl: "", method: "post", userAuth: true, parameters: params, postFields: postFields)
    }
    
    func update_location(params: Dictionary<String, String>){
        //location id in url, put
        //the only parameteres are the ields that need to be changed
        makeApiRequest("customer", endpointPath: "/location", pathTpl: "/:location_id", method: "put", userAuth: true, parameters: params, postFields: nil )
    }
    
    func modify_user_cart(params: Dictionary<String, String> ){
        // PUT /customer/cart/{merchant_id}
        //req cart_index, item, order_type
        //opt order_time, client_id
        makeApiRequest("customer", endpointPath: "/cart", pathTpl:"/:merchant_id", method: "put", userAuth: true, parameters: params, postFields: nil)
    }
    
    func clear_cart(params: Dictionary<String, String>){
        // DELETE /customer/cart/{merchant_id}
        //opt= cart_index, client_id
        
        makeApiRequest("customer", endpointPath: "/cart", pathTpl: "", method: "delete", userAuth: true, parameters: params, postFields: nil)
    }
    
    func place_order(params: Dictionary<String,String>){
        // POST /customer/cart/{merchant_id}/checkout
        var postFields = ["tip", "location_id", "instructions", "payments", "order_type", "order_time"]
        makeApiRequest("customer", endpointPath: "/cart", pathTpl: "/:merchant_id/cart", method: "post", userAuth: true, parameters: params, postFields: postFields)
    }
    
    func reorder_order(params: Dictionary<String, String>){
        // POST /api/customer/cart/reorder
        //order_id
        var postFields = ["order_id"];
        
        makeApiRequest("customer", endpointPath: "cart/reorder", pathTpl: "", method: "post", userAuth: true, parameters: params, postFields: nil)
    }
    
}