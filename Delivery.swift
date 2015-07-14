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
    
    private struct Static {
        static let keychain = KeychainWrapper()
    }
    
     func getToken() -> String {
        if let key: String = Static.keychain.myObjectForKey("v_Data").description {
            println("get token in delivery \(key)")
            return key
        }
        return ""
    }
    
     func setToken(token: String){
        println("set token \(token)")
        Static.keychain.mySetObject(token, forKey: kSecValueData)
        
    }
    
    func getExpiration() -> String{
        if let exp_date: String = Static.keychain.myObjectForKey(kSecAttrDescription).description {
            return exp_date
        }
        return "none"
    }
    
    func setExpiration(data: String) {
       Static.keychain.mySetObject(data, forKey: "desc")
    }
    
    
    //TODO: Would be smart to have the access token gotten and passed in before this
    init(apiKey: String, environment: String){
        self.apiKey = apiKey
        self.environment = environment
        self.clientId = apiKey
        
        if environment == "production" {
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
    
    func makeApiRequest( apiGroup: String, endpointPath: String, pathTpl: String, method: String, userAuth: Bool, parameters: Dictionary<String,AnyObject>!, postFields : [String]?, callback: (NSError?, AnyObject?) ->() ) {
        //used to set up path
        
        var uri = endpointPath
        var postData: Dictionary<String, AnyObject> = [:]
        var headerFields: Dictionary<String, String> = [:]
        var paramCount = 0
        var prefixChar = "?"
        for path in pathTpl.componentsSeparatedByString("/"){
            //if there is a colon provide the value, if no colon just use the word itself
            if path.hasPrefix(":") {
                var param = path.substringFromIndex(advance(path.startIndex, 1))
                uri += "/\(parameters[param]!)"
            }else if(path.hasPrefix("-")){
                var param = path.substringFromIndex(advance(path.startIndex, 1))
                uri += "\(prefixChar)\(param)=\(parameters[param]!)"
                //after the first parameter change query seperator
                prefixChar = "&"
            }else if(!path.isEmpty){
                uri += "/\(path)"
            }
        }
        
        //        https://api.delivery.com/merchant/search/pickup?address=199%20Water%20St%2010038&client_id=ODFlMWVhZWY2MWJhNzRhOTJhZDM2YThhZmU3Zjg1MGFh
        
        
        //initialize post fields if needed
        if(postFields != nil){
            for field in postFields!{
                if(parameters[field] != nil){
                    postData[field] = parameters[field]
                }
            }
        }
        
        if userAuth {
            //TODO: Deal with user authentication and access tokens
            // access token = gFxvucWb8ca0WugM5LYyCBOrr5Kl2mZxXEn6njRQ
            if ( getToken() != "password" ){
                println("headerfield")
                headerFields["Access token"] = getToken()
                headerFields["Authorization"] = getToken()

            }else{
                //re-authorize or something
            }
            
            
        }else{
            uri += "\(prefixChar)client_id=\(clientId)"
        }
        
        var encodedUrl : NSString = "\(urls[apiGroup]!)\(uri)"
        encodedUrl = encodedUrl.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        println("encoded url: \(encodedUrl)")
        
        if method == "post" {
            Agent.post(encodedUrl as! String, data: postData, done: { (error: NSError?, response: NSHTTPURLResponse?, data: NSMutableData?) -> () in
                if ((error) != nil) {
                    callback(error, nil)
                } else {
                    var results = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: nil) as! NSDictionary
                    callback(nil, results)
                }
            })
        } else if method == "put" {
            
        } else if method == "delete" {
            
        } else {
            println(encodedUrl.self)
            Agent.get(encodedUrl , headers: headerFields, done: { (error: NSError?, response: NSHTTPURLResponse?, data: NSMutableData?) -> () in
                println(encodedUrl.self)
                println("In get")
                if ((error) != nil) {
                    println("Agent get error")
                    callback(error, nil)
                } else {
                    println("Agent get print results")
                    var results : AnyObject! = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: nil)
                    callback(nil, results)
                }
            })
        }
    }
    
    func get_access_token(param: Dictionary<String, String>, callback: (NSError?, AnyObject?) -> ()) {
        var post = ["client_id", "redirect_uri", "grant_type", "client_secret", "code"]
        
        makeApiRequest("customer", endpointPath: "/third_party", pathTpl: "/:access_token", method: "post", userAuth: false, parameters: param, postFields: nil, callback: callback)
    }
    
    
    func get_guest_token( callback: (NSError?, AnyObject?) -> ()){
        //GET /customer/auth/guest
        
        makeApiRequest("customer", endpointPath: "auth/guest", pathTpl: "", method: "get", userAuth: false, parameters: nil, postFields: nil, callback: callback)
    }
    
    func get_saved_locations( callback: (NSError?, AnyObject?) -> ()){
        // GET/customer/location/
        
        makeApiRequest("customer", endpointPath: "location", pathTpl: "", method: "get", userAuth: true, parameters: nil, postFields: nil, callback: callback)
    }
    
    func get_user_cart(params: Dictionary<String, String>, callback: (NSError?, AnyObject?) -> ()){
        // GET /customer/cart/{merchant_id}
        // req order_type
        //opt = order_time, client_id
        //req for delivery= zip, city, state, latitude, longitude
        
        makeApiRequest("customer", endpointPath: "cart", pathTpl: "/:merchant_id", method: "get", userAuth: true, parameters: params, postFields: nil, callback: callback)
        
    }
    
    func get_guest_cart(){
        
    }
    
    func get_user_order(params: Dictionary<String, String>, callback: (NSError?, AnyObject?) -> ()){
        // GET /customer/orders/recent/{order_id}
        // order_id
        
        makeApiRequest("customer", endpointPath: "/orders/recent", pathTpl: "/:order_id", method: "get", userAuth: true, parameters: params, postFields: nil, callback: callback)
    }
    
    //order history
    func get_user_history(params: Dictionary<String, String>, callback: (NSError?, AnyObject?) -> ()){
        // GET /customer/orders/recent
        
        makeApiRequest("customer", endpointPath: "/orders/recent", pathTpl: "", method: "get", userAuth: true, parameters: nil, postFields: nil, callback: callback)
    }
    
    func get_customer_info(params: Dictionary<String,String>, callback: (NSError?, AnyObject?) -> ()){
        // GET /customer/account
        
        makeApiRequest("customer", endpointPath: "/account", pathTpl: "", method: "get", userAuth: true, parameters: params, postFields: nil, callback: callback)
    }
    
    func get_payments(params: Dictionary<String, String>, callback: (NSError?, AnyObject?) -> ()){
        // GET /customer/cart/{merchant_id}/checkout
        //req = order_time, order_type
        
        makeApiRequest("customer", endpointPath: "/cart", pathTpl: "/:merchant_id/checkout", method: "get", userAuth: true, parameters: params, postFields: nil, callback: callback)
    }
    
    func get_fav_orders( callback: (NSError?, AnyObject?) -> ()){
        // GET /api/customer/orders/favorite
        //TODO: Create endpoint url
        makeApiRequest("customer", endpointPath: "api/customer/orders/favorite", pathTpl: "", method: "get", userAuth: true, parameters: nil, postFields: nil, callback: callback)
    }
    
    func get_cc_request( callback: (NSError?, AnyObject?) -> ()){
        // GET /customer/cc
        //include_expired whether or not to include expired cards
        
        makeApiRequest("customer", endpointPath: "/cc", pathTpl: "", method: "get", userAuth: true, parameters: nil, postFields: nil, callback: callback)
    }
    
    func get_fav_merch( callback: (NSError?, AnyObject?) -> ()){
        // GET /api/merchant/favorite
        
        makeApiRequest("aMerchant", endpointPath: "/favorite", pathTpl: "", method: "get", userAuth: true, parameters: nil, postFields: nil, callback: callback)
    }
    
    func get_merch_info(params: Dictionary<String, String>, callback: (NSError?, AnyObject?) -> ()){
        //  GET /merchant/{merchant_id}/
        
        makeApiRequest("merchant", endpointPath: "", pathTpl: "/:merchant_id", method: "get", userAuth: false, parameters: params, postFields: nil, callback: callback)
        
    }
    
    func get_merch_menu(params: Dictionary<String, String>, callback: (NSError?, AnyObject?) -> ()){
        //GET /merchant/{merchant_id}/menu
        
        makeApiRequest("merchant", endpointPath: "", pathTpl: "/:merchant_id/menu", method: "get", userAuth: false, parameters: params, postFields: nil, callback: callback)
    }
    
    func find_merch(params: Dictionary<String, String>, callback: (NSError?, AnyObject?) -> ()){
        //GET /merchant/search/{method}
        //req method(delivery,pickup), address, latitude, logitude
        var pathTpl = "/:method/-address"
        if params["keyword"] != nil {
            pathTpl = pathTpl + "/-keyword"
        }
        
        makeApiRequest("merchant", endpointPath: "/search", pathTpl: pathTpl, method: "get", userAuth: false, parameters: params, postFields: nil, callback: callback)
        
    }
    
    func get_promotion(params: Dictionary<String, String>, callback: (NSError?, AnyObject?) -> ()){
        // POST /api/customer/promo/deal
        var postFields = ["deal_code"]
        makeApiRequest("aCustomer", endpointPath: "promod/deal", pathTpl: "", method: "post", userAuth: false, parameters: params, postFields: postFields, callback: callback)
    }
    
    func delete_location( callback: (NSError?, AnyObject?) -> ()){
        // DELETE /customer/location/{location_id}
        
        makeApiRequest("customer", endpointPath: "/location", pathTpl: "", method: "delete", userAuth: true, parameters: nil , postFields: nil, callback: callback )
    }
    
    func delete_fav_orders(){
        // DELETE /api/customer/orders/favorite/{order_id}
    }
    
    func delete_fav_merch(params: Dictionary<String, String>, callback: (NSError?, AnyObject?) -> ()){
        // DELETE /api/merchant/favorite/{merchant_id}
        
        makeApiRequest("aMerchant", endpointPath: "/favorite", pathTpl: "/:merchant_id", method: "delete", userAuth: true, parameters: params, postFields: nil, callback: callback)
    }
    
    func add_cc(){
        
    }
    
    func add_fav_order(params: Dictionary<String, String>, callback: (NSError?, AnyObject?) -> () ){
        // POST /api/customer/orders/favorite/{order_id}
        //order_name
        
        makeApiRequest("aCustomer", endpointPath: "/orders/favorite", pathTpl: "/:merchant_id", method: "post", userAuth: true, parameters: params, postFields: ["order_name"], callback: callback)
    }
    
    func add_fav_merch(params: Dictionary<String, String>, callback: (NSError?, AnyObject?) -> ()){
        // POST /api/merchant/favorite/{merchant_id}
        
        makeApiRequest("aMerchant", endpointPath: "/favorite", pathTpl: "/:merchant_id", method: "post", userAuth: true, parameters: params, postFields: nil, callback: callback)
    }
    
    func login_cred(){
        
    }
    
    func add_to_user_cart(params: Dictionary<String,String> , callback: (NSError?, AnyObject?) -> ()){
        // POST /customer/cart/{merchant_id}
        var postFields = ["order_type", "item"]
        makeApiRequest("customer", endpointPath: "cart", pathTpl: "/:merchant_id", method: "post", userAuth: true, parameters: params, postFields: postFields, callback: callback)
    }
    
    func add_to_guest_cart(params: Dictionary<String, String>, callback: (NSError?, AnyObject?) -> ()){
        // POST /customer/cart/{merchant_id}
        var postFields = ["item", "order_type"]
        makeApiRequest("customer", endpointPath: "/cart", pathTpl: "/:merchant_id", method: "post", userAuth: false, parameters: params, postFields: postFields, callback: callback)
    }
    
    func create_location(params : Dictionary<String, String>, callback: (NSError?, AnyObject?) -> ()){
        //req street, city, state abbr,zip, phone
        //optional unit number, company, street
        var required = ["street", "city", "state", "zip", "phone"]
        var postFields: [String] = [
            "street", "city", "state", "zip_code", "phone", "unit_number", "company", "street"
        ]
        
        makeApiRequest("customer", endpointPath: "/location", pathTpl: "", method: "post", userAuth: true, parameters: params, postFields: postFields, callback: callback)
    }
    
    func update_location(params: Dictionary<String, String>, callback: (NSError?, AnyObject?) -> ()){
        //location id in url, put
        //the only parameteres are the ields that need to be changed
        makeApiRequest("customer", endpointPath: "/location", pathTpl: "/:location_id", method: "put", userAuth: true, parameters: params, postFields: nil, callback: callback )
    }
    
    func modify_user_cart(params: Dictionary<String, String> , callback: (NSError?, AnyObject?) -> ()){
        // PUT /customer/cart/{merchant_id}
        //req cart_index, item, order_type
        //opt order_time, client_id
        makeApiRequest("customer", endpointPath: "/cart", pathTpl:"/:merchant_id", method: "put", userAuth: true, parameters: params, postFields: nil, callback: callback)
    }
    
    func clear_cart(params: Dictionary<String, String>, callback: (NSError?, AnyObject?) -> ()){
        // DELETE /customer/cart/{merchant_id}
        //opt= cart_index, client_id
        
        makeApiRequest("customer", endpointPath: "/cart", pathTpl: "", method: "delete", userAuth: true, parameters: params, postFields: nil, callback: callback)
    }
    
    func place_order(params: Dictionary<String,String>, callback: (NSError?, AnyObject?) -> ()){
        // POST /customer/cart/{merchant_id}/checkout
        var postFields = ["tip", "location_id", "instructions", "payments", "order_type", "order_time"]
        makeApiRequest("customer", endpointPath: "/cart", pathTpl: "/:merchant_id/cart", method: "post", userAuth: true, parameters: params, postFields: postFields, callback: callback)
    }
    
    func reorder_order(params: Dictionary<String, String>, callback: (NSError?, AnyObject?) -> ()){
        // POST /api/customer/cart/reorder
        //order_id
        var postFields = ["order_id"]
        
        makeApiRequest("customer", endpointPath: "cart/reorder", pathTpl: "", method: "post", userAuth: true, parameters: params, postFields: nil, callback: callback)
    }
    
    
    
}