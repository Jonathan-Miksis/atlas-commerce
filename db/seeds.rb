puts "Seeding Atlas Commerce database..."

# Clear existing data
Product.destroy_all
Category.destroy_all

# Categories
electronics = Category.create!(name: "Electronics", description: "B2B electronics and hardware solutions")
software    = Category.create!(name: "Software",    description: "Enterprise software licenses and subscriptions")
office      = Category.create!(name: "Office Supplies", description: "Bulk office and workplace supplies")
networking  = Category.create!(name: "Networking",  description: "Network infrastructure and equipment")

puts "Created #{Category.count} categories"

# Electronics
Product.create!([
  { name: "ThinkPad X1 Carbon",       sku: "ELEC-TP-X1C",  price: 1299.99, stock: 25, featured: true,  category: electronics, description: "14-inch ultrabook, Intel Core i7, 16GB RAM" },
  { name: "Dell UltraSharp 27 Monitor", sku: "ELEC-DELL-27", price: 549.00,  stock: 40, featured: false, category: electronics, description: "27-inch 4K USB-C monitor for professional use" },
  { name: "Logitech MX Keys Keyboard", sku: "ELEC-MX-KEY",  price: 119.99,  stock: 100, featured: false, category: electronics, description: "Advanced wireless keyboard for business" },
])

# Software
Product.create!([
  { name: "Atlas ERP Suite — Annual",  sku: "SW-ERP-ANN",   price: 4999.00, stock: 999, featured: true,  category: software, description: "Full ERP platform, up to 50 seats, annual license" },
  { name: "SecureVPN — 10 Seats",      sku: "SW-VPN-10",    price: 299.99,  stock: 999, featured: false, category: software, description: "Enterprise VPN solution, 10-seat pack" },
  { name: "DocuSign Business Pro",     sku: "SW-DOCU-BIZ",  price: 899.00,  stock: 999, featured: false, category: software, description: "eSignature platform, unlimited documents" },
])

# Office
Product.create!([
  { name: "Premium Paper — Case of 10", sku: "OFF-PAPER-10", price: 89.99,  stock: 200, featured: false, category: office, description: "Letter size, 8.5x11, 24lb, 96 brightness" },
  { name: "Ergonomic Chair — Mesh",     sku: "OFF-CHAIR-MH", price: 449.00, stock: 15,  featured: true,  category: office, description: "Adjustable lumbar support, breathable mesh back" },
  { name: "Standing Desk Converter",    sku: "OFF-DESK-SC",  price: 299.99, stock: 8,   featured: false, category: office, description: "Pneumatic lift, fits desks up to 72 inches" },
])

# Networking
Product.create!([
  { name: "Cisco Catalyst 1000 Switch", sku: "NET-CISCO-1K", price: 1899.00, stock: 10, featured: true,  category: networking, description: "24-port GbE, 4 SFP uplinks, enterprise managed" },
  { name: "Ubiquiti UniFi AP Pro",      sku: "NET-UB-AP-P",  price: 179.99,  stock: 35, featured: false, category: networking, description: "802.11ax WiFi 6, PoE, indoor/outdoor" },
  { name: "Patch Panel — 24 Port",      sku: "NET-PATCH-24", price: 64.99,   stock: 50, featured: false, category: networking, description: "Cat6, 1U rack mount, 568A/B compatible" },
])

puts "Created #{Product.count} products"
puts "Done! Atlas Commerce is ready."
