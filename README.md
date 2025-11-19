# Inventory-Database

## Entity Relationship Design
<img width="975" height="610" alt="image" src="https://github.com/user-attachments/assets/f34f3f13-e3ea-4c40-9996-ea5fc16c4b16" />

## Data Dictionary

### *Tables*
<img width="500" height="316" alt="image" src="https://github.com/user-attachments/assets/9542eac3-4839-44b6-9af7-74bc0dff2820" />

### *Department*
<img width="975" height="213" alt="image" src="https://github.com/user-attachments/assets/e22947ec-77cc-4b4f-a9fc-019577517796" />

Provides a list of the subgroups within the department and their respective contacts and information.

### *Inventory*
<img width="975" height="309" alt="image" src="https://github.com/user-attachments/assets/46523a04-ce75-4faf-9ba4-7f309cff6582" />

Item locations within the department that tracks how many  items are in stock and their max capacity within their stock location.

### *Order Instance*
<img width="975" height="264" alt="image" src="https://github.com/user-attachments/assets/84bcfeb2-94be-4bce-be55-c3f3987e12d6" />

Relates individual items to a completed Purchase Order (PO).

### *Orders*
<img width="975" height="287" alt="image" src="https://github.com/user-attachments/assets/3d3bc6a8-32a9-46ec-be1d-33acf39cd307" />

Carries information about the overall PO. Receipt column references a receipt in which the order was completed in total. Entry into this column triggers a completed entry into the receipt and receipt_instance table. If this value is left null, the user may enter individual items received to indicate that a partial receipt has been received within the receipt table.

### *Receipt*
<img width="975" height="266" alt="image" src="https://github.com/user-attachments/assets/9bc2cd42-43c0-4a0b-a8d6-282ec7e5015d" />

Logs when an order is received in Materials Management (the receiving department) and within the department to track any potential delays in receipt.

### *Receipt Instance*
<img width="975" height="242" alt="image" src="https://github.com/user-attachments/assets/79266933-9733-4f89-812f-1659eb756c62" />

Similar to the order_instance table, receipt_instance notes the receipt of individual items and relates them back to the receipt which may consist of many items.

### *Supplies*
<img width="975" height="287" alt="image" src="https://github.com/user-attachments/assets/4f4e2539-2fe3-4588-9b3d-758839236fe5" />

Describes the attributes of individual items used in the department.

### *Vendor*
<img width="975" height="357" alt="image" src="https://github.com/user-attachments/assets/496ee504-6f76-4486-827c-232bbcba770a" />

Table of Vendor details and contact information.

## Views

<img width="746" height="211" alt="image" src="https://github.com/user-attachments/assets/1c226b1f-0f7d-4af3-a3b5-9ddc1574cfb7" />

### *View - Item order history*
<img width="909" height="271" alt="image" src="https://github.com/user-attachments/assets/42139ce2-6c1b-4a8e-b39b-1ff81113966e" />

View which provides a fuller and more comprehensive look at items, which have been ordered and arranged by a descending date. Joins orders, order_instance, and supplies.  

<img width="975" height="393" alt="image" src="https://github.com/user-attachments/assets/5816a8c5-1fdb-4a08-b312-f98db83e9395" />

### *View - Orders*
<img width="931" height="198" alt="image" src="https://github.com/user-attachments/assets/88ea2d3e-2fd3-4efc-a437-d80edfa53c22" />

Lists orders, but also includes a total count of items and cost column for a user to assess the overall cost of an order.

<img width="478" height="133" alt="image" src="https://github.com/user-attachments/assets/d0df206f-87a9-485e-be37-ca67afda68b5" />

### *View - Turn around*
<img width="914" height="244" alt="image" src="https://github.com/user-attachments/assets/a206d1bc-f4d3-479e-b746-5d35aacbb59f" />

A view which provides information regarding the amount of time between placing a PO and the receipt of the order.

<img width="975" height="167" alt="image" src="https://github.com/user-attachments/assets/ddd8d814-2bcf-40ba-833e-601129c3f302" />

### *View - Average turn around*
<img width="946" height="199" alt="image" src="https://github.com/user-attachments/assets/55953699-474b-4b43-946c-11e776ba6c85" />

Provides the user with information regarding each individual item and the average time it takes to return after order.

