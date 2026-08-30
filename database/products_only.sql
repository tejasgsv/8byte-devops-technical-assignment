INSERT INTO products (name, description, category, price, stock, created_at, updated_at) VALUES
-- Infrastructure Products (8)
('Cloud Infrastructure Starter', 'Perfect for small teams getting started with cloud infrastructure. Includes basic compute, storage, and networking.', 'infrastructure', 499.99, 100, NOW(), NOW()),
('Enterprise Cloud Suite', 'Complete cloud solution for large enterprises with 99.99% uptime SLA and 24/7 support.', 'infrastructure', 2999.99, 50, NOW(), NOW()),
('API Gateway Pro', 'High-performance API gateway with rate limiting, authentication, and analytics built-in.', 'infrastructure', 799.99, 80, NOW(), NOW()),
('Database Cluster Manager', 'Manage PostgreSQL, MySQL, and MongoDB clusters with automated backups and failover.', 'infrastructure', 1299.99, 45, NOW(), NOW()),
('Load Balancer Elite', 'Enterprise-grade load balancing with SSL termination and health checks.', 'infrastructure', 1799.99, 35, NOW(), NOW()),
('Container Orchestrator', 'Simplified container orchestration with Kubernetes under the hood.', 'infrastructure', 1599.99, 55, NOW(), NOW()),
('CDN Accelerator', 'Global content delivery network with edge caching and DDoS protection.', 'infrastructure', 899.99, 70, NOW(), NOW()),
('Message Queue System', 'Reliable message queuing with RabbitMQ and Redis Streams support.', 'infrastructure', 699.99, 90, NOW(), NOW()),

-- Software Products (8)
('DevOps Automation Platform', 'Streamline your CI/CD pipeline with our comprehensive automation tools and integrations.', 'software', 1499.99, 75, NOW(), NOW()),
('Kubernetes Management Console', 'Simplified Kubernetes cluster management with visual dashboards and one-click deployments.', 'software', 999.99, 60, NOW(), NOW()),
('Microservices Toolkit', 'Everything you need to build, deploy, and monitor microservices at scale.', 'software', 599.99, 90, NOW(), NOW()),
('Redis Cache Optimizer', 'Optimize your Redis performance with intelligent caching strategies and monitoring.', 'software', 399.99, 120, NOW(), NOW()),
('Code Quality Analyzer', 'Automated code review and quality analysis for multiple programming languages.', 'software', 449.99, 85, NOW(), NOW()),
('Test Automation Suite', 'End-to-end testing automation with support for web, mobile, and API testing.', 'software', 799.99, 65, NOW(), NOW()),
('Monitoring Dashboard Pro', 'Real-time monitoring with custom dashboards, alerts, and integrations.', 'software', 899.99, 70, NOW(), NOW()),
('Log Analytics Platform', 'Centralized log management with powerful search and analysis capabilities.', 'software', 699.99, 80, NOW(), NOW()),

-- Security Products (4)
('Security Monitoring Suite', 'Real-time security monitoring and threat detection with AI-powered analysis.', 'security', 1999.99, 40, NOW(), NOW()),
('Vulnerability Scanner Pro', 'Automated vulnerability scanning for web applications and infrastructure.', 'security', 1299.99, 50, NOW(), NOW()),
('Identity Access Manager', 'Enterprise IAM solution with SSO, MFA, and role-based access control.', 'security', 1599.99, 45, NOW(), NOW()),
('Firewall & DDoS Protection', 'Advanced firewall with machine learning-based DDoS mitigation.', 'security', 2499.99, 30, NOW(), NOW())
ON CONFLICT DO NOTHING;
