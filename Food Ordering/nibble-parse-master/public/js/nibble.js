// An example Parse.js Backbone application based on the todo app by
// [Jérôme Gravel-Niquet](http://jgn.me/). This demo uses Parse to persist
// the todo items and provide user authentication and sessions.

$(function() {

  Parse.$ = jQuery;

  // Initialize Parse with your Parse application javascript keys
  Parse.initialize("zFLGCSep1Jefdj9ZqCU69q59kKmiS9Tx9j33CCAI",
                   "4aRwGTfI6Dm6vypWATWmhMIP0Oe38oZ370sn8aJi");


  // --------------------------------------------------------------------

  var Restaurants=Parse.Collection.extend({
  });
  // control view
  var RestaurantList=Parse.View.extend({
    el:'.page',
    events: {
         "click .log-out": "logOut",
         "click .view-restuarant": "viewRestuarant",
       },

      my_template: _.template("<strong>testing</strong>"),
    initialize: function() {

      _.bindAll(this, 'logOut','viewRestuarant');
      this.render();

    },
     //function for logOut action
    logOut: function(e) {
     Parse.User.logOut();
     new LogInView();
     this.undelegateEvents();
     delete this;
     location.reload();
   },

   viewRestuarant: function(e) {
    console.log("viewRestuarant");
    new restruantview();
    this.undelegateEvents();
    delete this;
    //location.reload();
   },

    render:function(){
      var self=this;
      var restaurants = new Restaurants();

      self.$el.html("Restaurants show here!!!!!!!!!"+"<hr/>");
      this.$el.html(_.template($("#logInOut").html()));

/*--------------------------------------------------------------------------------------------------------*/
//display user order history
      var delieryTime;
      //console.log("current user: "+Parse.User.current().get("username"));
       $( ".page" ).append("<br><button type=\"button\" class=\"btn btn-success view-restuarant\">view restaurants</button>");
       if(Parse.User.current().get("firstName")!=null){
         $( ".page" ).append("<h3>"+"user: "+Parse.User.current().get("firstName")+"<h3>");
       }else{
         $( ".page" ).append("<h3>"+"user: "+Parse.User.current().get("username")+"<h3>");
       }

        if(Parse.User.current().get("profilePicture")!=null)
        $( ".page" ).append( "<img src=" + Parse.User.current().get("profilePicture")._url +" "+"style="+"width:50px;height:50px;"+">");


      //start from user
      var user=Parse.User.current();

      var ordersRelation = user.relation("orders");//user relation
      var ordersQuery =ordersRelation.query( );
      var currentuserOrder;
      //visiting database different fields
      ordersQuery.include("restaurant");  //visiting restaurant
      ordersQuery.include("assignedPost");  //visiting assignedPost
      ordersQuery.include("assignedPost.deliveryLocation");//deliveryLocation
      ordersQuery.include("assignedPost.restaurant");//restaurant
      //ordersQuery.include("assignedPost.deliveryTime")
      ordersQuery.include("driver");//driver

      ordersQuery.find({
          success: function(orders) {
            //console.log(orders.length);
            if(orders.length==0){
              $( ".page" ).append("<h3>"+"You don't have any order"+"</h3>" );
            }

            // Do something with the returned Parse.Object values
            for (var i = 0; i < orders.length; i++) {
              var order= orders[i];
              var assignedPost=order.get("assignedPost");
              var restaurantPointer = order.get("restaurant");
              var drivername;
              var contactinfo;
              var profilePicture;
              var restaurantname;
              var restaurantthumbnailURL;
              if(restaurantPointer!=null){
                restaurantname=restaurantPointer.get("name");
                restaurantthumbnailURL=restaurantPointer.get("thumbnailURL")
              }
              if(order.get("driver")!=null){

                if(order.get("driver").get("firstName")!=null)
                  drivername=order.get("driver").get("firstName");
                else
                  drivername=order.get("driver").get("username");

                contactinfo=order.get("driver").get("email");

                if(order.get("driver").get("profilePicture")!=null){
                   profilePicture=order.get("driver").get("profilePicture")._url;
                 }
                else if(order.get("driver").get("profilePictureURL")!=null){
                  profilePicture=order.get("driver").get("profilePictureURL");
                }
              }

              if(assignedPost!=null){
                  //get restruant's name

                    delieryTime=order.get("assignedPost").get("deliveryTime");
                    var deliveryto=assignedPost.get("deliveryLocation").get("name");
                    var deliveryfrom=assignedPost.get("restaurant").get("name");
                    console.log("order: "+i);
                    console.log(order);

                    // show delivery status
                    var status;
                    if(order.get("delivered")==true){
                      status="delivered";
                    }else if (order.get("delivered")==false&&order.get("cancelled")==false) {
                      status="out for delivery";
                    }else {
                      status="cancelled";
                    }

                   /*display the data on web   */
                    //console.log("order: "+i+", restaurant name: "+restaurantPointer.get("name"));
                    $( ".page" ).append("<hr>"+"<h4>"+"Order ID: "+order.id+"</h4><h4>"+restaurantname+"</h4>" );
                    $( ".page" ).append("<img src=" + restaurantthumbnailURL +" "+"style="+"width:150px;height:150px;"+">");
                    $( ".page" ).append( "<div class=\"detail"+i+"\"><b>Driver: </b>"+drivername+" <b>&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbspContact Info:</b> "+contactinfo+"</div>" );
                    //if(order.get("driver").get("profilePicture")!=null)
                    $( ".page" ).append("<img src=" +profilePicture +" "+"style="+"width:50px;height:50px;"+">");
                    $( ".page" ).append( "<p><b>Items:</b> "+order.get("text")+"</p>" );
                    if(restaurantPointer!=null)
                    $( ".page" ).append( "<p><b>Delivering To: </b>"+deliveryto+"&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Delivering From: </b>"+restaurantPointer.get("name")+"</p>" );
                    $( ".page" ).append( "<p><b>Deliery Time: </b>"+delieryTime+"</p>" );
                    $( ".page" ).append("<p><b>status: </b>"+status+"</p>");
                    //console.log("delivery to: "+deliveryto+", delivery from: "+restaurantPointer.get("name"));
                    console.log("deliery Time: "+delieryTime);
                    console.log("status: "+status);
              }else{

                $( ".page" ).append("<hr>"+"<h4>"+"Order ID: "+order.id+"</h4><h4>"+restaurantname+"</h4>" );
                $( ".page" ).append("<img src=" + restaurantthumbnailURL +" "+"style="+"width:150px;height:150px;"+">");
                $( ".page" ).append( "<p><b>Items:</b> "+order.get("text")+"</p>" );
                $( ".page" ).append("<p><b>status: </b>pending</p>");
              }
            }
          },
          error: function(error) {
            console.log("no order");
          }
        });
    }
  });
     //view control
   var restruantview = Parse.View.extend({

      el: ".page",
      events: {
           "click .log-out": "logOut",
           "click .vieworder": "vieworder",
         },

       logOut: function(e) {
        Parse.User.logOut();
        new LogInView();
        this.undelegateEvents();
        delete this;
        location.reload();
      },

      vieworder: function(e) {
       new RestaurantList();
       this.undelegateEvents();
       delete this;

     },
      initialize: function() {
        _.bindAll(this, 'logOut','vieworder');
      this.render();
      },

      render:function(){
        var self=this;
        console.log("restview");
        this.$el.html(_.template($("#logInOut").html()));
         $( ".page" ).append("<br><button type=\"button\" class=\"btn btn-success vieworder\">view orders</button>");
        Parse.Cloud.run("validRestaurants", {}, {
          success: function(result) {

            for(i=0;i<result.length;i++){
             $( ".page" ).append( "<hr/>"+"<p>"+result[i].get("name")+"</p>" );
             $( ".page" ).append( "<img src=" + result[i].get("thumbnailURL") +" "+"style="+"width:128px;height:128px;"+">");
             $( ".page" ).append("<p>price: "+result[i].get("priceTier")+"</p>" );
             $( ".page" ).append( "<p>category: "+result[i].get("categories")+"</p>" );
             //$( ".page" ).append("<button type="+"button"+ "class="+"btn btn-primary"+">"+"select"+"</button>");
              //console.log(result[i].get("name"));
            }

          },
          error: function(error) {
            response.error(error.message);
          }
        });
      }

   });

    //login view control
  var LogInView = Parse.View.extend({
      events: {
        "submit form.login-form": "logIn",
        "submit form.signup-form": "signUp"
      },

      el: ".content",

      initialize: function() {
        _.bindAll(this, "logIn", "signUp");
        this.render();
      },

      logIn: function(e) {
        var self = this;
        var username = this.$("#login-username").val();
        var password = this.$("#login-password").val();
         //function for login
        Parse.User.logIn(username, password, {
          success: function(user) {
            delete self;
            location.reload();
            new RestaurantList();
            self.undelegateEvents();

          },

          error: function(user, error) {
            self.$(".login-form .error").html("Invalid username or password. Please try again.").show();
            self.$(".login-form button").removeAttr("disabled");
          }
        });

        this.$(".login-form button").attr("disabled", "disabled");

        return false;
      },
      // function for signup
      signUp: function(e) {
        var self = this;
        var username = this.$("#signup-username").val();
        var password = this.$("#signup-password").val();

        Parse.User.signUp(username, password, { ACL: new Parse.ACL() }, {
          success: function(user) {
            delete self;
            location.reload();
            self.undelegateEvents();
            new RestaurantList();


          },

          error: function(user, error) {
            self.$(".signup-form .error").html(_.escape(error.message)).show();
            self.$(".signup-form button").removeAttr("disabled");
          }
        });

        this.$(".signup-form button").attr("disabled", "disabled");

        return false;
      },

      render: function() {
        this.$el.html(_.template($("#login-template").html()));
        this.delegateEvents();
      }
    });
  // The main view for the app
  var AppView = Parse.View.extend({
    // Instead of generating a new element, bind to the existing skeleton of
    // the App already present in the HTML.
    el: $("#todoapp"),

    initialize: function() {
      //console.log("AppView");

      this.render();
    },

    render: function() {
      console.log(Parse.User.current());
      if (Parse.User.current()) {
       new RestaurantList();

      } else {
        new LogInView();

      }
    }
  });

  var Router = Parse.Router.extend({
        routes: {
          "": "home",
        },

        home: function(){
        console.log("user:"+Parse.User.current());
        new AppView();
      	}

    });

    new Router;

  Parse.history.start();
});
