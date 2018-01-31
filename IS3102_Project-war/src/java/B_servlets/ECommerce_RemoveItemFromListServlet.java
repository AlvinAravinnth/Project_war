/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package B_servlets;

import HelperClasses.ShoppingCartLineItem;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Iterator;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 *
 * @author mandf
 */
@WebServlet(name = "ECommerce_RemoveItemFromListServlet", urlPatterns = {"/ECommerce_RemoveItemFromListServlet"})
public class ECommerce_RemoveItemFromListServlet extends HttpServlet {

    ArrayList<ShoppingCartLineItem> shoppingCart;
      
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        try
        {
            HttpSession session = request.getSession();
            shoppingCart = (ArrayList<ShoppingCartLineItem>) session.getAttribute("shoppingCart");
            String[] checkBoxes = request.getParameterValues("delete");
            System.out.println("shoppingCart list :" + shoppingCart.size());
            System.out.println("checkboxes length :" + checkBoxes.length); 
            int noOfItems = 0;
                for(Iterator<ShoppingCartLineItem> iterator = shoppingCart.iterator(); iterator.hasNext();)
                {
                    ShoppingCartLineItem shoppingCartLineItem = iterator.next();
                    for (String SKU : checkBoxes) {
                        System.out.println("SKU :" + SKU);
                        System.out.println("shoppingCartLineItem.getSKU :" + shoppingCartLineItem.getSKU());  
                        if(shoppingCartLineItem.getSKU().equals(SKU))
                        {
                            noOfItems++; 
                            iterator.remove();
                        }
                    }
                }
                session.setAttribute("shoppingCart", shoppingCart);
                response.sendRedirect("/IS3102_Project-war/B/SG/shoppingCart.jsp?goodMsg=Successfully removed: " + noOfItems + " record(s).");
        }
        catch(Exception ex)
        {
            out.println("\n\n " + ex.getMessage());
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
