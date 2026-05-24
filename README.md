> **⚠️ Project Status: Under Development**  

# AWS Security Monitoring & Automated CIS Compliance

This project implements a production-grade, serverless security monitoring and threat detection architecture on AWS using **Terraform (Infrastructure as Code)**. It continuously collects API logs, analyzes compliance against CIS benchmarks, and forwards security events to **Datadog** for centralized SIEM visualization.

## 🏗️ Architecture Overview
---

![Diagram](assets/awsSecuritMonitoring_2.drawio.svg)

---

The system architecture consists of two main pipelines:
1. **Log Collection & Visualization:** AWS CloudTrail captures multi-region API activities -> Stores them securely in an S3 Bucket (with Log File Validation) -> Streams logs to Datadog for security analytics and dashboarding.
2. **Threat Detection & Compliance (In Progress):** AWS GuardDuty detects intelligent threats, while AWS Config monitors CIS AWS Foundations Benchmark compliance.

## 🛠️ Tech Stack & Services
* **Infrastructure as Code:** Terraform (Modular Structure)
* **Security & Logging:** AWS CloudTrail, AWS Config, AWS GuardDuty
* **Storage:** Amazon S3 (Hardened with Public Access Blocks & Strict Bucket Policies)
* **SIEM & Analytics:** Datadog

## 📂 Project Structure
```text
.
├── main.tf                 # Root Terraform configuration (Module orchestrator)
└── modules/
    ├── s3/                 # Hardened S3 bucket deployment & policies
    ├── cloudtrail/         # Multi-region CloudTrail configuration
    └── datadog/            # AWS-Datadog integration infrastructure