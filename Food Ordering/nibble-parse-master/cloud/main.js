require('cloud/app.js');

// Don't save a Foursquare location if we already have it
Parse.Cloud.beforeSave("Location", function(request, response) {
	var location = request.object;
	var query = new Parse.Query("Location");

	if (location.get("postCount") == undefined) {
		location.set("postCount", 0);
	}
	
	query.equalTo("foursquareID", request.object.get("foursquareID"));
	query.first({
		success: function(result) {
			if (result == undefined || result.id.localeCompare(request.object.id) == 0) {
				// We're updating the object, so allow the save
				response.success(location);
			} else {
				// Object already exists, skip it
				var errorDictionary = {message: "Location with that Foursquare ID already exists.", objectId: result.id};
				response.error(JSON.stringify(errorDictionary));
			}
		},
		error: function(error) {
			response.error(error.message);
		}
	});
});

// Don't save a Foursquare photo if we already have it
Parse.Cloud.beforeSave("Photo", function(request, response) {
	var query = new Parse.Query("Photo");
	query.equalTo("foursquareID", request.object.get("foursquareID"));
	query.first({
		success: function(result) {
			if (result == undefined) {
				response.success();
			} else {
				// Object already exists, skip it
				var errorDictionary = {message: "Photo with that Foursquare ID already exists.", objectId: result.id};
				response.error(JSON.stringify(errorDictionary));
			}
		},
		error: function(error) {
			response.error(error.message);
		}
	});
});

// Creating posts
Parse.Cloud.beforeSave("Post", function(request, response) {
	var post = request.object;

	if (post.isNew()) {
		// Set user param on order
		post.set("driver", request.user.toPointer());
	}

	response.success();
});

Parse.Cloud.afterSave("Post", function(request, response) {
	var post = request.object;

	if (request.user.id == post.get("driver").id) {
		// Save post under driver's posts relation
		request.user.get("posts").add(post);
	}

	// Add post to restaurants' posts field
	var locationQuery = new Parse.Query("Location");
	locationQuery.get(post.get("restaurant").id, {
		success: function(restaurant) {
			var postsRelation = restaurant.get("posts");
			if (post.get("active") == true) {
				// Add post + increment postCount
				// Add post if necessary
				var postsRelationQuery = postsRelation.query();
				postsRelationQuery.equalTo("objectId", post.id);
				postsRelationQuery.first ({
					success: function(existingPost) {
						if (existingPost == undefined) {
							postsRelation.add(post);
							restaurant.increment("postCount", 1);
						}
						
						// Save
						var toSave = [request.user, restaurant];
						Parse.Object.saveAll(toSave, {
							success: function(results) {},
							error: function(error) { console.log(error.message); }
						});
					},
					error: function(error) { console.log(error.message); }
				});
			} else {
				// Remove post + decrement postCount
				postsRelation.remove(post);
				restaurant.increment("postCount", -1);
				Parse.Object.saveAll([request.user, restaurant], {
					success: function(results) {},
					error: function(error) { console.log(error.message); }
				});
			}
		},
		error: function(error) {
			console.log(error.message);
		}
	})
});

// Creating orders
Parse.Cloud.beforeSave("Order", function(request, response) {
	var order = request.object;

	// Set user param on order
	if (order.isNew() == true && order.get("user") == undefined) {
		order.set("user", request.user.toPointer());
	}

	response.success();
});

// Creating orders
Parse.Cloud.afterSave("Order", function(request, response) {
	var order = request.object;

	// Add order to the user's orders
	var ordersQuery = request.user.get("orders").query();
	ordersQuery.equalTo("objectId", order.id);
	ordersQuery.include("user");
	ordersQuery.include("user.appInstallation");
	ordersQuery.include("restaurant");
	ordersQuery.include("assignedPost");
	ordersQuery.include("assignedPost.driver");
	ordersQuery.include("assignedPost.deliveryLocation");
	ordersQuery.first({
		success: function(result) {
			if (result == undefined) {
				// New order, add it to the user's orders
				request.user.get("orders").add(order);
			} else {
				// Updating the order
				var delivered = order.get("delivered");
				var pickedUp = order.get("pickedUp");
				if (delivered == true || pickedUp == true) {
					var alertTitle = delivered ? "Delivered" : "Picked Up";

					var driverName = order.get("assignedPost").get("driver").get("firstName");
					var restaurantName = order.get("restaurant").get("name");
					var deliveryLocationName = order.get("assignedPost").get("deliveryLocation").get("name");
					var alertBody = "Your order from " + restaurantName + " was " + (delivered ? ("delivered at " + deliveryLocationName) : ("picked up by " + driverName + " and is en route to " + deliveryLocationName)) + ".";

					// Send a push to all potential drivers
					var pushQuery = new Parse.Query(Parse.Installation);
					pushQuery.equalTo("objectId", order.get("user").get("appInstallation").id);
					Parse.Push.send({
						where: pushQuery,
						data: {
							alert: {title: alertTitle, body: alertBody},
						}
					}, {
						success: function() {},
						error: function(error) { console.log(error.message); }
					});
				}
			}

			if (order.get("assignedPost") == undefined) {
				// Iterate over requestedPosts
				var requestedPostsQuery = order.get("requestedPosts").query();
				requestedPostsQuery.include("driver");
				requestedPostsQuery.include("driver.driverAppInstallation");
				requestedPostsQuery.find({
					success: function(requestedPosts) {
						// Edit pendingOrders
						for (i in requestedPosts) {
							var post = requestedPosts[i];
							if (order.get("cancelled") == true) {
								post.get("pendingOrders").remove(order);
							} else {
								post.get("pendingOrders").add(order);

								// Send a push to all potential drivers
								var pushQuery = new Parse.Query(Parse.Installation);
								pushQuery.equalTo("objectId", post.get("driver").get("driverAppInstallation").id);
								Parse.Push.send({
									where: pushQuery,
									data: {
										alert: {title: "Order Request", body: request.user.get("firstName") + " ordered \"" + order.get("text") + "\"."},
										category: "ORDER_REQUEST",
										objectId: order.id 
									}
								}, {
									success: function() {},
									error: function(error) { console.log(error.message); }
								});
							}
						}

						// Save all posts
						var toSave = requestedPosts.concat([request.user]);
						Parse.Object.saveAll(toSave, {
							success: function(list) {},
							error: function(error) {
								console.log(error);
							},
						})
					},
					error: function(error) {
						console.log(error.message);
					}
				});
			}
		},
		error: function(error) {
			console.log(error.message);
		}
	});
});

Parse.Cloud.define("validRestaurants", function(request, response) {
	var query = new Parse.Query("Location");
	query.greaterThanOrEqualTo("postCount", 1);
	query.descending("postCount");
	query.find({
		success: function(results) {
			response.success(results);
		},
		error: function(error) {
			response.error(error.message);
		}
	});
});

// Allow the current user (a driver) to accept orders
//
// PARAMETERS:
// objectId - object ID of an order to accept
//
Parse.Cloud.define("acceptOrder", function(request, response) {
	var postsRelation = request.user.get("posts");
	var postsQuery = postsRelation.query();
	postsQuery.descending("createdAt");
	postsQuery.include("deliveryLocation");
	postsQuery.first({
		success: function(currentPost) {
			// We have the user's current post
			var pendingOrdersRelation = currentPost.get("pendingOrders");
			var pendingOrdersQuery = pendingOrdersRelation.query();
			pendingOrdersQuery.include("user");
			pendingOrdersQuery.include("user.appInstallation");
			pendingOrdersQuery.include("restaurant");
			pendingOrdersQuery.equalTo("objectId", request.params.objectId);

			var acceptedOrdersRelation = currentPost.get("acceptedOrders");
			pendingOrdersQuery.first({
				success: function(matchedOrder) {
					// Remove order from pending orders
					pendingOrdersRelation.remove(matchedOrder);

          			// Add order to accepted orders
					acceptedOrdersRelation.add(matchedOrder);

					// Add driver to order
					matchedOrder.set("driver", request.user.toPointer());

					// Send a push to the person who placed the order
					var pushQuery = new Parse.Query(Parse.Installation);
					pushQuery.equalTo("objectId", matchedOrder.get("user").get("appInstallation").id);
					var appInstallation = matchedOrder.get("user").get("appInstallation");
					var restaurant = matchedOrder.get("restaurant");

					var utcTime = currentPost.get("deliveryTime");
					var millisecondsSince1970 = utcTime.getTime();
					var eightHoursInMilliseconds = 8 * 3600 * 1000;
					var millisecondsConverted = millisecondsSince1970 - eightHoursInMilliseconds;
					var convertedDate = new Date(millisecondsConverted);
					var hours = convertedDate.getHours();
					if (convertedDate.getHours() > 12) { hours -= 12; }
					var minutes = convertedDate.getMinutes(); 
					var minuteString = minutes < 10 ? ("0" + minutes.toString()) : minutes.toString();
					var AMPMString = convertedDate.getHours() > 12 ? "PM" : "AM";

					Parse.Push.send({
						where: pushQuery,
						data: {
							alert: {title: "Driver Assigned", body: request.user.get("firstName") + " will deliver your order from " + restaurant.get("name") + " to " + currentPost.get("deliveryLocation").get("name") + " at " + hours + ":" + minuteString + " " + AMPMString + "."}
						}
					}, {
						success: function() {},
						error: function(error) { console.log(error.message); }
					});

					// Set the post as that order's assignedPost
					var Post = Parse.Object.extend("Post");
					var assignedPost = new Post();
					assignedPost.id = currentPost.id;
					matchedOrder.set("assignedPost", assignedPost);

					// Remove post from order's requestedPosts
					matchedOrder.get("requestedPosts").remove(currentPost);

					// Remove order from all other posts' pendingOrders
					var requestedPostsQuery = matchedOrder.get("requestedPosts").query();
					requestedPostsQuery.find({
						success: function(posts) {
							for (i in posts) {
								var post = posts[i];
								post.get("pendingOrders").remove(matchedOrder);
							}

							var toSave = [matchedOrder, currentPost];
							toSave.concat(posts);
							Parse.Object.saveAll(toSave, {
								success: function(results) {},
								error: function(error) { console.log(error.message); }
							});
						},
						error: function(error) {
							console.log(error.message);
						}
					});

					// Save
					matchedOrder.save();
					currentPost.save();
				},
				error: function(error) {
					console.log(error.message);
				}
			});
		},
		error: function(error) {
			console.log(error.message);
		}
	});
});

// Allow the current user (a driver) to reject orders
//
// PARAMETERS:
// objectId - object ID of an order to reject
//
Parse.Cloud.define("rejectOrder", function(request, response) {
	var postsRelation = request.user.get("posts");
	var postsQuery = postsRelation.query();
	postsQuery.descending("createdAt");
	postsQuery.first({
		success: function(currentPost) {
			// We have the user's current post
			var pendingOrdersRelation = currentPost.get("pendingOrders");
			var pendingOrdersQuery = pendingOrdersRelation.query();
			pendingOrdersQuery.include("restaurant");
			pendingOrdersQuery.include("user");
			pendingOrdersQuery.include("user.appInstallation");
			pendingOrdersQuery.equalTo("objectId", request.params.objectId);
			pendingOrdersQuery.first({
				success: function(matchedOrder) {
					// Remove order from post
					pendingOrdersRelation.remove(matchedOrder);

					// Remove post from order
					var requestedPostRelation = matchedOrder.get("requestedPosts");
					requestedPostRelation.remove(currentPost);

					// Check if any requested posts remain
					var requestedPostsQuery = requestedPostRelation.query();
					requestedPostsQuery.find({
						success: function(requestedPosts) {
							// Cancel order if no more requestedPosts
							var aboutToRemoveLastPost = requestedPosts.length == 1 && requestedPosts[0].id == currentPost.id;
							if (aboutToRemoveLastPost) {
								matchedOrder.set("cancelled", true);

								var pushQuery = new Parse.Query(Parse.Installation);
								pushQuery.equalTo("objectId", matchedOrder.get("user").get("appInstallation").id);
								Parse.Push.send({
									where: pushQuery,
									data: {
										alert: {title: "Order Cancelled", body: "Unfortunately, no drivers were available to deliver your order from " + matchedOrder.get("restaurant").get("name") + ". Sorry about that!"}
									}
								}, {
									success: function() {},
									error: function(error) { console.log(error.message); }
								});
							}

							// Save all
							Parse.Object.saveAll([matchedOrder, currentPost], {
								success: function(results) {},
								error: function(error) { console.log(error.message); }
							});
						},
						error: function(error) {}
					});
				},
				error: function(error) {
					console.log(error.message);
				}
			});
		},
		error: function(error) {
			console.log(error.message);
		}
	});
});
