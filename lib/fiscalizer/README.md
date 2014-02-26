# Fiscalizer

Fiscalizer is the main class of this gem. It interacts with all other classes, handles certificate decription and connection establishment.

Methods:

 * `echo` : Creates an echo request to the fiscalization servers
 * `fiscalize_office` : Creates or recives an office object and fiscalizes it (alias methods `office` and `fiscalize_office_space`)
 * `fiscalize_invoice` : Creates or recives an invoice object and fiscalizes it (alias methods `invoice`)