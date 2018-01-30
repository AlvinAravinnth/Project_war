<%@page import="java.text.DecimalFormat"%>
<%@page import="java.util.*"%>
<%@page import="HelperClasses.ShoppingCartLineItem"%>
<%@page import="EntityManager.WishListEntity"%>
<%@page import="EntityManager.Item_CountryEntity"%>
<%@page import="EntityManager.FurnitureEntity"%>
<%@page import="EntityManager.RetailProductEntity"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:include page="checkCountry.jsp" />
<!--###-->
<html> <!--<![endif]-->
    <jsp:include page="header.html" />
    <body>
        <%
            double finalPrice = 0.0;
            DecimalFormat df = new DecimalFormat("#0.00");
        %>
        <script>
            var totalPrice = 0;
            for (var i = 0, n = shoppingCart.getItems().size; i < n; i++) {
                totalPrice += shoppingCart.getItems().get(i).get
            }
            function removeItem() {
                checkboxes = document.getElementsByName('delete');
                var sku = '';
                var numOfTicks = 0;
                for (var i = 0, n = checkboxes.length; i < n; i++) {
                    if (checkboxes[i].checked) {
                        numOfTicks++;
                        sku += checkboxes[i].value + ':';
                    }
                }
                if (checkboxes.length == 0 || numOfTicks == 0) {
                    window.event.returnValue = true;
                    document.shoppingCart.action = "/IS3102_Project-war/B/SG/shoppingCart.jsp?errMsg=No item(s) selected for deletion.";
                    document.shoppingCart.submit();
                } else {
                    window.event.returnValue = true;
                    document.shoppingCart.action = "../../ECommerce_RemoveItemFromListServlet?SKU=" + sku;
                    document.shoppingCart.submit();
                }
            }
            function checkAll(source) {
                checkboxes = document.getElementsByName('delete');
                for (var i = 0, n = checkboxes.length; i < n; i++) {
                    checkboxes[i].checked = source.checked;
                }
            }
            function minus(SKU) {
                window.event.returnValue = true;
                document.shoppingCart.action = "../../ECommerce_MinusFurnitureToListServlet?SKU=" + SKU;
                document.shoppingCart.submit();
            }
            function plus(ID, SKU, name, price, imageURL) {
                window.event.returnValue = true;
                document.shoppingCart.action = "../../ECommerce_AddFurnitureToListServlet?id=" + ID + "&SKU=" + SKU + "&price=" + price + "&name=" + name + "&imageURL=" + imageURL + "&fromJsp=no";
                document.shoppingCart.submit();
            }
            function finalTotalPrice() {
                checkboxes = document.getElementsById('totalPrice');
                for (var i = 0, n = checkboxes.length; i < n; i++) {
                    checkboxes[i].checked = source.checked;
                }
            }
            function checkOut() {
                $(".plus").prop("disabled", true);
                $(".minus").prop("disabled", true);
                $("#btnCheckout").prop("disabled", true);
                $("#btnRemove").prop("disabled", true);
                $(".productDetails").removeAttr("href");
                $(".minus").attr("style","cursor: not-allowed;");
                $(".plus").attr("style","cursor: not-allowed;");
                $("html, body").animate({scrollTop: $(document).height() / 3}, "slow");
                $("#makePaymentForm").show("slow", function () {
                });
            }
        </script>

        <div class="body">
            <jsp:include page="menu2.jsp" />
            <div role="main" class="main shop">
                <section class="page-top">
                    <div class="container">
                        <div class="row">
                            <div class="col-md-12">
                                <h2>Shopping Cart</h2>
                            </div>
                        </div>
                    </div>
                </section> 

                <div class="container" id="printableArea">
                    <hr class="tall">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="row featured-boxes">
                                <div class="col-md-12">
                                    <div class="featured-box featured-box-secundary featured-box-cart">
                                        <div class="box-content">
                                            <form method="post" action="" name="shoppingCart">
                                                <jsp:include page="/displayMessageLong.jsp" />
                                                <table cellspacing="0" class="shop_table cart">
                                                    <thead>
                                                        <tr>                                                                
                                                            <th class="product-remove">
                                                                <input type="checkbox" onclick="checkAll(this)" />
                                                            </th>                                                                
                                                            <th class="product-thumbnail">
                                                                Image
                                                            </th>
                                                            <th class="product-name" >
                                                                Product
                                                            </th>

                                                            <th class="product-price" style="width: 15%">
                                                                Price
                                                            </th>
                                                            <th class="product-quantity">
                                                                Quantity
                                                            </th>
                                                            <th class="product-subtotal" style="width: 15%">
                                                                Subtotal
                                                            </th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <%ArrayList<ShoppingCartLineItem> shoppingCart = (ArrayList<ShoppingCartLineItem>) (session.getAttribute("shoppingCart"));
                                                            try {
                                                                if (shoppingCart != null && shoppingCart.size() > 0) {
                                                                    for(ShoppingCartLineItem item : shoppingCart) {
                                                        %>
                                                        <tr class="cart_table_item">
                                                            <td class="product-remove">
                                                                <input type="checkbox" name="delete" value="<%=item.getSKU()%>" />
                                                            </td>
                                                            <td class="product-thumbnail">
                                                                <a href="furnitureProductDetails.jsp?sku=<%=item.getSKU()%>">
                                                                    <img width="100" height="100" alt="" class="img-responsive" src="../../..<%=item.getImageURL()%>">
                                                                </a>
                                                            </td>
                                                            <td class="product-name">
                                                                <a class="productDetails" href="furnitureProductDetails.jsp?sku=<%=item.getSKU()%>"><%=item.getName()%></a>
                                                            </td>
                                                            <td class="product-price">
                                                                $<span class="amount" id="price<%=item.getSKU()%>">
                                                                    <%=df.format(item.getPrice())%>
                                                                </span>
                                                            </td>
                                                            <td class="product-quantity">
                                                                <form enctype="multipart/form-data" method="post" class="cart">
                                                                    <div class="quantity">
                                                                        <input type="button" id="btnMinus" class="minus" value="-" onclick="minus('<%=item.getSKU()%>')">
                                                                        <input type="text" disabled="true" class="input-text qty text" title="Qty" value="<%=item.getQuantity()%>" name="quantity" min="1" step="1" id="<%=item.getSKU()%>">
                                                                        <input type="button" id="btnPlus" class="plus" value="+" onclick="plus('<%=item.getId()%>', '<%=item.getSKU()%>', '<%=item.getName()%>',<%=item.getPrice()%>, '<%=item.getImageURL()%>')">
                                                                    </div>
                                                                </form>
                                                            </td>
                                                            <td class="product-subtotal">
                                                                $<span class="amount" id="totalPrice<%=item.getSKU()%>">
                                                                    <%
                                                                        finalPrice += item.getPrice() * item.getQuantity();
                                                                        out.print(df.format(item.getPrice() * item.getQuantity()));
                                                                    %>
                                                                </span>
                                                            </td>
                                                        </tr>
                                                        <%
                                                                    }                                                         //   }
                                                                }
                                                            } catch (Exception ex) {
                                                                System.out.println(ex);
                                                            }
                                                        %>
                                                        <tr>
                                                            <td></td>
                                                            <td></td>
                                                            <td></td>
                                                            <td></td>
                                                            <td class="product-subtotal" style="font-weight: bold">
                                                                Total:
                                                            </td>
                                                            <td class="product-subtotal">
                                                                $<span class="amount" id="finalPrice" name="finalPrice">
                                                                    <%=df.format(finalPrice)%>
                                                                </span>
                                                            </td>
                                                        </tr>
                                                    </tbody>
                                                </table>
                                                <%if (shoppingCart != null && shoppingCart.size() > 0) {%>
                                                <div align="left"><a href="#myModal" data-toggle="modal"><button id="btnRemove" class="btn btn-primary">Remove Item(s)</button></a></div>
                                                <div align="right"><a href="#checkoutModal" data-toggle="modal"><button id="btnCheckout" class="btn btn-primary btn-lg">Check Out</button></a></div>

                                                <%} else {%>
                                                <div align="right" style="cursor: not-allowed;"><a href="#checkoutModal" data-toggle="modal"><button disabled="true" id="btnCheckout" class="btn btn-primary btn-lg">Check Out</button></a></div>
                                                <%}%>
                                            </form>


                                            <form id="makePaymentForm" action="../../ECommerce_PaymentServlet" name="makePaymentForm" method="post" hidden>
                                                <div class="col-md-8">
                                                    <br>
                                                    <br>
                                                    <table>
                                                        <tbody>
                                                            <tr>
                                                                <h4 style="text-align: left">Credit Card Payment Details</h4>
                                                            </tr>
                                                        <tr>
                                                            <td style="padding: 5px">
                                                                <label>Name on Card: </label>
                                                            </td>
                                                            <td style="padding: 5px">
                                                                <input type="text" class="input-text text" pattern="[A-Za-z]+" title="Please enter a valid name" id="txtName" required>                                                            
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="padding: 5px">
                                                                <label>Card Number: </label>
                                                            </td>
                                                            <td style="padding: 5px">
                                                                <input type="text" class="input-text text " maxlength="16" pattern="\d{16}|\d{4}[- ]\d{4}[- ]\d{4}[- ]\d{4}" title="Please provide a 16 credit card number format." title="cardno" id="txtCardNo" required>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="padding: 5px">
                                                                <label>CVV/CVC2: </label>
                                                            </td>
                                                            <td style="padding: 5px">
                                                                <input type="text" class="input-text text " type="number" maxlength="3" pattern="\d{3}" title="Please provide a valid cvv number" id="txtSecuritycode" required>
                                                            </td>
                                                        </tr>

                                                        <tr>
                                                            <td style="padding: 5px;">
                                                                <label>Expiry Date: </label>
                                                            </td>
                                                            <td style="width: 300px">
                                                                <select style="width: 120px; display: inline-block" class="dropdown-header" title="Month">
                                                                    <option>January</option>
                                                                    <option>February</option>
                                                                    <option>March</option>
                                                                    <option>April</option>
                                                                    <option>May</option>
                                                                    <option>June</option>
                                                                    <option>July</option>
                                                                    <option>August</option>
                                                                    <option>September</option>
                                                                    <option>October</option>
                                                                    <option>November</option>
                                                                    <option>December</option>
                                                                </select>
                                                                <input type="text" style="width: 60px" pattern="\d{4}" class="input-text text" title="Please enter a valid year" id="year" required>  (eg: 2015)                                                        
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <h4 style="text-align: left">Pick up store</h4>
                                                                <select class="dropdown" name="pickUpStore" title="Location">
                                                                    <option>Queenstown Store</option>
                                                                    <option>Kent Ridge Store</option>
                                                                    <option>Tampines Store</option>
                                                                </select>                                                
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="padding-top: 20px">
                                                                <div align="left"><input type="submit" value="Make Payment" class="btn btn-primary"></div>
                                                            </td>
                                                        </tr>
                                                        </tbody></table>
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div role="dialog" class="modal fade" id="myModal">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h4>Remove item(s)</h4>
                        </div>
                        <div class="modal-body">
                            <p id="messageBox">The selected item(s) will be removed from your shopping cart. Are you sure you want to continue?</p>
                        </div>
                        <div class="modal-footer">                        
                            <input class="btn btn-primary" name="btnRemove" type="submit" value="Confirm" onclick="removeItem()"  />
                            <a class="btn btn-default" data-dismiss ="modal">Close</a>
                        </div>
                    </div>
                </div>
            </div>
            <div role="dialog" class="modal fade" id="checkoutModal">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h4>Checking out...</h4>
                        </div>
                        <div class="modal-body">
                            <p id="messageBox">Please check the cart items before checkout. Are you sure you want to continue?</p>
                        </div>
                        <div class="modal-footer">                        
                            <input class="btn btn-primary" data-dismiss ="modal" name="btnCheckout" type="button" value="Confirm" onclick="checkOut()"  />
                            <a class="btn btn-default" data-dismiss ="modal">Close</a>
                        </div>
                    </div>
                </div>
            </div>  

            <div role="dialog" class="modal fade" id="makePaymentModal">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h4>Confirm Payment</h4>
                        </div>
                        <div class="modal-body">
                            <p id="messageBox">You are making payment now. Are you sure you want to continue?</p>
                        </div>
                        <div class="modal-footer">                        
                            <input class="btn btn-primary" name="btnPayment" type="submit" value="Confirm" onclick="makePayment()"  />
                            <a class="btn btn-default" data-dismiss ="modal">Close</a>
                        </div>
                    </div>
                </div>
            </div>

            <jsp:include page="footer.html" />

            <!-- Theme Initializer -->
            <script src="../../js/theme.plugins.js"></script>
            <script src="../../js/theme.js"></script>

            <!-- Current Page JS -->
            <script src="../../vendor/rs-plugin/js/jquery.themepunch.tools.min.js"></script>
            <script src="../../vendor/rs-plugin/js/jquery.themepunch.revolution.js"></script>
            <script src="../../vendor/circle-flip-slideshow/js/jquery.flipshow.js"></script>
            <script src="../../js/views/view.home.js"></script>   
        </div>
    </body>
</html>
