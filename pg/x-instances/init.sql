-- Create Users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    phone_number VARCHAR(15),
    address TEXT,
    city VARCHAR(50),
    postal_code VARCHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Buses table
CREATE TABLE buses (
    id SERIAL PRIMARY KEY,
    bus_number VARCHAR(20) UNIQUE NOT NULL,
    capacity INT NOT NULL,
    model VARCHAR(100),
    registration_number VARCHAR(50),
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Routes table
CREATE TABLE routes (
    id SERIAL PRIMARY KEY,
    route_name VARCHAR(100) NOT NULL,
    start_location VARCHAR(100) NOT NULL,
    end_location VARCHAR(100) NOT NULL,
    distance_km DECIMAL(10, 2),
    estimated_duration_minutes INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Bus Schedules table
CREATE TABLE bus_schedules (
    id SERIAL PRIMARY KEY,
    bus_id INT NOT NULL,
    route_id INT NOT NULL,
    departure_time TIME NOT NULL,
    arrival_time TIME NOT NULL,
    schedule_date DATE NOT NULL,
    available_seats INT NOT NULL,
    status VARCHAR(20) DEFAULT 'scheduled',
    FOREIGN KEY (bus_id) REFERENCES buses(id) ON DELETE CASCADE,
    FOREIGN KEY (route_id) REFERENCES routes(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Ticket Prices table
CREATE TABLE ticket_prices (
    id SERIAL PRIMARY KEY,
    route_id INT NOT NULL,
    ticket_type VARCHAR(50) NOT NULL,
    base_price DECIMAL(10, 2) NOT NULL,
    discount_percentage DECIMAL(5, 2) DEFAULT 0,
    description TEXT,
    valid_from DATE,
    valid_until DATE,
    FOREIGN KEY (route_id) REFERENCES routes(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Payment Methods table
CREATE TABLE payment_methods (
    id SERIAL PRIMARY KEY,
    method_name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Purchases table
CREATE TABLE purchases (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    bus_schedule_id INT NOT NULL,
    ticket_price_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    purchase_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (bus_schedule_id) REFERENCES bus_schedules(id) ON DELETE CASCADE,
    FOREIGN KEY (ticket_price_id) REFERENCES ticket_prices(id) ON DELETE CASCADE
);

-- Create Payments table
CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    purchase_id INT NOT NULL,
    payment_method_id INT NOT NULL,
    amount_paid DECIMAL(10, 2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    transaction_reference VARCHAR(100) UNIQUE,
    payment_status VARCHAR(20) DEFAULT 'pending',
    FOREIGN KEY (purchase_id) REFERENCES purchases(id) ON DELETE CASCADE,
    FOREIGN KEY (payment_method_id) REFERENCES payment_methods(id) ON DELETE SET NULL
);

-- Create Tickets table
CREATE TABLE tickets (
    id SERIAL PRIMARY KEY,
    purchase_id INT NOT NULL,
    ticket_number VARCHAR(50) UNIQUE NOT NULL,
    bus_schedule_id INT NOT NULL,
    ticket_type VARCHAR(50),
    seat_number VARCHAR(10),
    price DECIMAL(10, 2) NOT NULL,
    valid_from TIMESTAMP,
    valid_until TIMESTAMP,
    status VARCHAR(20) DEFAULT 'active',
    used_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (purchase_id) REFERENCES purchases(id) ON DELETE CASCADE,
    FOREIGN KEY (bus_schedule_id) REFERENCES bus_schedules(id) ON DELETE CASCADE
);

-- Create indexes for better query performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_buses_bus_number ON buses(bus_number);
CREATE INDEX idx_bus_schedules_date ON bus_schedules(schedule_date);
CREATE INDEX idx_purchases_user_id ON purchases(user_id);
CREATE INDEX idx_purchases_status ON purchases(status);
CREATE INDEX idx_payments_purchase_id ON payments(purchase_id);
CREATE INDEX idx_tickets_user_id ON tickets(purchase_id);
CREATE INDEX idx_tickets_status ON tickets(status);

-- Insert Sample Data

-- Insert Payment Methods
INSERT INTO payment_methods (method_name, description, is_active) VALUES
('Credit Card', 'Visa, Mastercard, Amex', TRUE),
('Debit Card', 'All bank debit cards', TRUE),
('PayPal', 'PayPal wallet', TRUE),
('Bank Transfer', 'Direct bank transfer', TRUE),
('Mobile Payment', 'Mobile wallet payments', TRUE);

-- Insert Routes
INSERT INTO routes (route_name, start_location, end_location, distance_km, estimated_duration_minutes) VALUES
('Downtown to Airport', 'Downtown Station', 'Airport Terminal', 25.5, 45),
('City Center Loop', 'City Center', 'Suburbs', 18.0, 35),
('Express Route 101', 'North Station', 'South Terminal', 40.0, 60),
('Coastal Highway', 'Beach Town', 'Mountain Resort', 55.0, 90);

-- Insert Buses
INSERT INTO buses (bus_number, capacity, model, registration_number, status) VALUES
('BUS-001', 50, 'Mercedes Sprinter', 'ABC123XYZ', 'active'),
('BUS-002', 50, 'Mercedes Sprinter', 'ABC124XYZ', 'active'),
('BUS-003', 60, 'Volvo B11R', 'ABC125XYZ', 'active'),
('BUS-004', 60, 'Volvo B11R', 'ABC126XYZ', 'maintenance');

-- Insert Ticket Prices
INSERT INTO ticket_prices (route_id, ticket_type, base_price, discount_percentage, description) VALUES
(1, 'Adult', 12.50, 0, 'Full price ticket'),
(1, 'Student', 12.50, 25, 'Student discount 25%'),
(1, 'Senior', 12.50, 30, 'Senior citizen discount 30%'),
(2, 'Adult', 8.00, 0, 'Full price ticket'),
(2, 'Student', 8.00, 25, 'Student discount 25%'),
(3, 'Adult', 18.50, 0, 'Express route premium'),
(3, 'Student', 18.50, 25, 'Student discount 25%'),
(4, 'Adult', 22.00, 0, 'Long distance premium'),
(4, 'Student', 22.00, 25, 'Student discount 25%'),
(4, 'Group', 22.00, 15, 'Group of 10+ discount');

-- Insert Sample Bus Schedules
INSERT INTO bus_schedules (bus_id, route_id, departure_time, arrival_time, schedule_date, available_seats, status) VALUES
(1, 1, '06:00:00', '06:45:00', '2026-02-01', 45, 'scheduled'),
(1, 1, '08:30:00', '09:15:00', '2026-02-01', 50, 'scheduled'),
(2, 1, '10:00:00', '10:45:00', '2026-02-01', 48, 'scheduled'),
(3, 2, '07:15:00', '07:50:00', '2026-02-01', 55, 'scheduled'),
(3, 2, '14:30:00', '15:05:00', '2026-02-01', 60, 'scheduled'),
(1, 3, '06:30:00', '07:30:00', '2026-02-01', 50, 'scheduled');

-- Insert Sample Users
INSERT INTO users (username, email, password_hash, first_name, last_name, phone_number, city) VALUES
('john_doe', 'john@example.com', '$2b$12$example_hash_1', 'John', 'Doe', '555-1001', 'Downtown'),
('jane_smith', 'jane@example.com', '$2b$12$example_hash_2', 'Jane', 'Smith', '555-1002', 'Suburbs'),
('mike_brown', 'mike@example.com', '$2b$12$example_hash_3', 'Mike', 'Brown', '555-1003', 'City Center'),
('lisa_white', 'lisa@example.com', '$2b$12$example_hash_4', 'Lisa', 'White', '555-1004', 'Airport');

-- Insert Sample Purchases
INSERT INTO purchases (user_id, bus_schedule_id, ticket_price_id, quantity, total_amount, status, purchase_date) VALUES
(1, 1, 1, 1, 12.50, 'completed', CURRENT_TIMESTAMP - INTERVAL '1 day'),
(2, 3, 6, 2, 37.00, 'completed', CURRENT_TIMESTAMP - INTERVAL '2 hours'),
(3, 4, 4, 1, 8.00, 'pending', CURRENT_TIMESTAMP),
(4, 2, 2, 1, 9.38, 'completed', CURRENT_TIMESTAMP - INTERVAL '5 hours');

-- Insert Sample Payments
INSERT INTO payments (purchase_id, payment_method_id, amount_paid, payment_date, transaction_reference, payment_status) VALUES
(1, 1, 12.50, CURRENT_TIMESTAMP - INTERVAL '1 day', 'TXN-2026-0001', 'completed'),
(2, 2, 37.00, CURRENT_TIMESTAMP - INTERVAL '2 hours', 'TXN-2026-0002', 'completed'),
(3, 3, 8.00, CURRENT_TIMESTAMP, 'TXN-2026-0003', 'pending'),
(4, 1, 9.38, CURRENT_TIMESTAMP - INTERVAL '5 hours', 'TXN-2026-0004', 'completed');

-- Insert Sample Tickets
INSERT INTO tickets (purchase_id, ticket_number, bus_schedule_id, ticket_type, seat_number, price, valid_from, valid_until, status) VALUES
(1, 'TICKET-2026-000001', 1, 'Adult', 'A1', 12.50, '2026-02-01 06:00:00', '2026-02-01 06:45:00', 'used'),
(2, 'TICKET-2026-000002', 3, 'Student', 'B5', 18.50, '2026-02-01 10:00:00', '2026-02-01 10:45:00', 'active'),
(2, 'TICKET-2026-000003', 3, 'Student', 'B6', 18.50, '2026-02-01 10:00:00', '2026-02-01 10:45:00', 'active'),
(3, 'TICKET-2026-000004', 4, 'Adult', 'C3', 8.00, '2026-02-01 07:15:00', '2026-02-01 07:50:00', 'active'),
(4, 'TICKET-2026-000005', 2, 'Student', 'A10', 9.38, '2026-02-01 08:30:00', '2026-02-01 09:15:00', 'used');
