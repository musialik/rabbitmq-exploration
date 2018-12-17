/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import { Socket } from 'phoenix'
import { addOrderRow, updateOrderRow, addDeliveryRow } from 'lib/dom'

let socket = new Socket("ws://localhost:4000/socket", { params: { userToken: "nothing" } })

socket.connect()

// Orders

let orders = socket.channel("orders", { token: "nothing" })

orders.on("orders.created", order => {
  console.log('adding order', order)
  let table = document.getElementById('orders-table').getElementsByTagName('tbody')[0]

  addOrderRow(table, order)
})

orders.on("orders.updated", order => {
  console.log('updating order', order)
  let row = document.getElementById(`order-${order.id}`)
  updateOrderRow(row, order)
})

orders.join()
  .receive("ok", (res) => console.log(res) )
  .receive("error", ({ reason }) => console.log("failed join", reason) )
  .receive("timeout", () => console.log("Networking issue. Still waiting..."))

// Deliveries

let deliveries = socket.channel("deliveries", { token: "nothing" })

deliveries.on("deliveries.created", delivery => {
  console.log('adding delivery',delivery)
  let table = document.getElementById('deliveries-table').getElementsByTagName('tbody')[0]

  addDeliveryRow(table, delivery)
})

deliveries.join()
  .receive("ok", (res) => console.log(res) )
  .receive("error", ({ reason }) => console.log("failed join", reason) )
  .receive("timeout", () => console.log("Networking issue. Still waiting..."))
