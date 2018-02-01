/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package B_servlets;

import EntityManager.StoreEntity;
import HelperClasses.Member;
import HelperClasses.ShoppingCartLineItem;
import com.sun.mail.smtp.SMTPTransport;
import java.io.IOException;
import java.io.PrintWriter;
import java.security.Security;
import java.util.ArrayList;
import java.util.Date;
import java.util.Properties;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.ws.rs.client.Client;
import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.client.Entity;
import javax.ws.rs.client.Invocation;
import javax.ws.rs.client.WebTarget;
import javax.ws.rs.core.Form;
import javax.ws.rs.core.GenericType;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

public class ECommerce_PaymentServlet extends HttpServlet {
    
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        try {
            HttpSession session = request.getSession();
            ArrayList<ShoppingCartLineItem> shoppingCart = new ArrayList<ShoppingCartLineItem>();
            double totalPrice = 0.0;
            if (session.getAttribute("shoppingCart") != null) {
                shoppingCart = (ArrayList<ShoppingCartLineItem>) session.getAttribute("shoppingCart");
                String storeName = request.getParameter("pickUpStore");
                for (ShoppingCartLineItem cartItem : shoppingCart) {
                    totalPrice += cartItem.getPrice() * cartItem.getQuantity();
                }
                Member member = (Member) session.getAttribute("member");
                int recordId = CreateECommerceTransactionRecord(member, storeName, totalPrice);
                boolean isValid = true;
                boolean quantityValid = true;
                String itemNotValid = "";
                int itemNotValidQuantity = 0;
                if (recordId != -1) {
                    for (ShoppingCartLineItem item : shoppingCart) {
                        int qty = getQuantity(Long.parseLong("10001"), item.getSKU());
                        if ((qty - item.getQuantity()) < 0) {
                            quantityValid = false;
                            itemNotValid = item.getName();
                            itemNotValidQuantity = qty;
                        }
                    }
                    if (quantityValid) {
                        for (ShoppingCartLineItem item : shoppingCart) {
                            int qty = getQuantity(Long.parseLong("10001"), item.getSKU());
                            if ((qty - item.getQuantity()) >= 0) {
                                CreateECommerceLineItemRecord(item, recordId);
                                totalPrice += item.getPrice() * item.getQuantity();
                            } else {
                                response.sendRedirect("/IS3102_Project-war/B/SG/shoppingCart.jsp?errMsg=We do not have enough \'" + item.getName() + "\' to answer your request,"
                                        + " the current stock we have for " + item.getName() + " is " + qty + ".");
                                isValid = false;
                            }
                        }

                    } else {
                        response.sendRedirect("/IS3102_Project-war/B/SG/shoppingCart.jsp?errMsg=We do not have enough \'" + itemNotValid + "\' to answer your request,"
                                        + " the current stock we have for " + itemNotValid + " is " + itemNotValidQuantity + ".");
                        isValid = false;
                    }
                }

                if (isValid == true) {
                    String storeAddress = getStore(storeName);
                    session.setAttribute("shoppingCart", null);
                    response.sendRedirect("/IS3102_Project-war/B/SG/shoppingCart.jsp?goodMsg=Successfully paid. Your item can be collected from "
                            + storeName + " located at " + storeAddress);
                }
            }
        } catch (Exception ex) {
            out.println("\n\n " + ex.getMessage() + ex);
        }
    }
    
    public String getStore(String storeName) {
        try {
            Client client = ClientBuilder.newClient();
            WebTarget target = client
                    .target("http://localhost:8080/IS3102_WebService-Student/webresources/entity.storeentity")
                    .path("getStoreAddress")
                    .queryParam("storeName", storeName);
            Invocation.Builder invocationBuilder = target.request(MediaType.APPLICATION_JSON);
            Response response = invocationBuilder.get();
            if (response.getStatus() != 200) {
                return "";
            }
            
            String storeAddress = response.readEntity(String.class);
            return storeAddress;

        } catch (Exception e) {
            e.printStackTrace();
            return "";
        }
    }
    
    public int CreateECommerceTransactionRecord(Member mem, String storeName, double totalPrice){
        Client client = ClientBuilder.newClient();
        WebTarget target = client
                .target("http://localhost:8080/IS3102_WebService-Student/webresources/entity.commerce")
                .path("CreateECommerceTransactionRecord");
        
        Form f = new Form();
        f.param("amountPaid", String.valueOf(totalPrice));
        f.param("memberId", String.valueOf(mem.getId()));
        f.param("storeName", storeName);
        
        Invocation.Builder invocationBuilder = target.request();
        Response response = invocationBuilder.post(Entity.entity(f, MediaType.APPLICATION_FORM_URLENCODED));
        
        System.out.println("create transaction record status: " + response.getStatus());
        if (response.getStatus() != 200) {
            return -1;
        }
        
        String recordId = response.readEntity(String.class);
        return Integer.parseInt(recordId);
    }
    
    public boolean CreateECommerceLineItemRecord(ShoppingCartLineItem cart, int recordId){
        Client client = ClientBuilder.newClient();
        WebTarget target = client
                .target("http://localhost:8080/IS3102_WebService-Student/webresources/entity.commerce")
                .path("CreateECommerceLineItemRecord");
        
        Form f = new Form();
        f.param("quantity", String.valueOf(cart.getQuantity()));
        f.param("SKU", cart.getSKU());
        f.param("transactionRecordId", String.valueOf(recordId));
        
        Invocation.Builder invocationBuilder = target.request();
        Response response = invocationBuilder.post(Entity.entity(f, MediaType.APPLICATION_FORM_URLENCODED));
        
        System.out.println("create line item status: " + response.getStatus());

        if (response.getStatus() != 200) {
            return false;
        }
        return true;
    }
    
    public int getQuantity(Long storeID, String SKU) {
        try {
            Client client = ClientBuilder.newClient();
            WebTarget target = client
                    .target("http://localhost:8080/IS3102_WebService-Student/webresources/entity.storeentity")
                    .path("getQuantity")
                    .queryParam("storeID", storeID)
                    .queryParam("SKU", SKU);
            Invocation.Builder invocationBuilder = target.request(MediaType.APPLICATION_JSON);
            Response response = invocationBuilder.get();
            if (response.getStatus() != 200) {
                return -1;
            }
            String result = (String) response.readEntity(String.class);
            return Integer.parseInt(result);

        } catch (Exception e) {
            e.printStackTrace();
            return -1;
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
