export const addOrderRow = (table, order) => {
  let rowCount = table.rows.length

  if (rowCount == 20) {
    table.deleteRow(rowCount - 1)
  }

  let row = table.insertRow(0)
  row.id = `order-${order.id}`
  updateOrderRow(row, order)
  
  table.insertBefore(row, table.firstChild)
}

export const updateOrderRow = (row, order) => {
  row.innerHTML = `
    <td>${order.location}</td>
    <td>${order.commodity}</td>
    <td>${order.quantity}</td>
    <td>${order.status}</td>
  `
  return row
}

export const addDeliveryRow = (table, delivery) => {
  let rowCount = table.rows.length

  if (rowCount == 15) {
    table.deleteRow(rowCount - 1)
  }

  let row = table.insertRow(0)
  row.id = `delivery-${delivery.id}`
  row.innerHTML = `
    <td>${delivery.location}</td>
    <td>${delivery.commodities.join('<br />')}</td>
  `

  table.insertBefore(row, table.firstChild)
}
