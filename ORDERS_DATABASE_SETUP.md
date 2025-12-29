# Database Schema untuk Orders

Untuk menyimpan hasil checkout ke database, Anda perlu membuat 2 tabel di Supabase:

## 1. Tabel `orders`

```sql
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  customer_name TEXT NOT NULL,
  customer_email TEXT NOT NULL,
  shipping_address TEXT NOT NULL,
  city TEXT,
  postal_code TEXT,
  subtotal DECIMAL(12, 2) NOT NULL,
  shipping_cost DECIMAL(12, 2) NOT NULL,
  total DECIMAL(12, 2) NOT NULL,
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index untuk user_id
CREATE INDEX idx_orders_user_id ON orders(user_id);

-- Index untuk created_at untuk sorting
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);
```

## 2. Tabel `order_items`

```sql
CREATE TABLE order_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id TEXT NOT NULL,
  product_name TEXT NOT NULL,
  price DECIMAL(12, 2) NOT NULL,
  quantity INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index untuk order_id
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
```

## 3. Row Level Security (RLS)

Enable RLS dan buat policies:

```sql
-- Enable RLS
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- Policy untuk orders: user hanya bisa lihat ordernya sendiri
CREATE POLICY "Users can view their own orders"
  ON orders FOR SELECT
  USING (auth.uid() = user_id);

-- Policy untuk orders: user bisa insert order baru
CREATE POLICY "Users can insert their own orders"
  ON orders FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy untuk order_items: user bisa lihat items dari ordernya
CREATE POLICY "Users can view their order items"
  ON order_items FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM orders
      WHERE orders.id = order_items.order_id
      AND orders.user_id = auth.uid()
    )
  );

-- Policy untuk order_items: user bisa insert items
CREATE POLICY "Users can insert order items"
  ON order_items FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM orders
      WHERE orders.id = order_items.order_id
      AND orders.user_id = auth.uid()
    )
  );
```

## Cara Setup di Supabase:

1. Buka Supabase Dashboard
2. Pilih project Anda
3. Klik "SQL Editor" di sidebar
4. Copy-paste SQL di atas (satu per satu atau sekaligus)
5. Jalankan query

Setelah tabel dibuat, aplikasi akan otomatis menyimpan order ke database saat user klik "Place Order".
