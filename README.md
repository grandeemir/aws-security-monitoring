# 🛡️ AWS Security Monitoring & Compliance

<p align="center">
  <img src="https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white" alt="AWS">
  <img src="https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform">
  <img src="https://img.shields.io/badge/Datadog-%23632CA6.svg?style=for-the-badge&logo=datadog&logoColor=white" alt="Datadog">
  <img src="https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge" alt="License">
</p>

<p align="center">
  <strong>A professional, production-ready security infrastructure built with Terraform.</strong><br>
  Monitor threats, ensure compliance, and visualize everything in one place.
</p>

---

## 📋 Table of Contents
- [Overview](#-overview)
- [Key Features](#-key-features)
- [Architecture](#-architecture)
- [Technologies Used](#-technologies-used)
- [Getting Started](#-getting-started)
- [Project Structure](#-project-structure)

---

## 🔍 Overview
This project automates the setup of a secure AWS environment. It follows the **CIS AWS Foundations Benchmark** to ensure your cloud infrastructure is safe, monitored, and compliant. All logs are centralized and forwarded to **Datadog** for real-time analysis.

---

## 🌟 Key Features

| Feature | Description |
| :--- | :--- |
| **🔍 24/7 Monitoring** | Full activity tracking via **AWS CloudTrail**. |
| **🚨 Threat Detection** | Intelligent threat analysis with **AWS GuardDuty**. |
| **✅ Compliance** | Automatic best-practice checks using **AWS Config** & **Security Hub**. |
| **📊 SIEM Integration** | Beautiful dashboards and alerts in **Datadog**. |
| **🔎 SQL Analytics** | High-speed log querying using **AWS Athena**. |
| **🔒 Hardened S3** | Encrypted storage with blocked public access. |

---

## 🏗️ Architecture

<p align="center">
  <img src="assets/awsSecuritMonitoring_2.drawio.svg" width="800" alt="Architecture Diagram">
</p>

The security pipeline flows as follows:
1. **Ingest:** CloudTrail and GuardDuty capture all system events.
2. **Secure:** Logs are encrypted and saved in a private S3 bucket.
3. **Audit:** AWS Config monitors for any misconfigurations.
4. **Visualize:** Datadog provides a "single pane of glass" view for your security team.

---

## 🛠️ Technologies Used

### Core Cloud Services
- ![CloudTrail](https://img.shields.io/badge/AWS_CloudTrail-orange?style=flat-square)
- ![GuardDuty](https://img.shields.io/badge/AWS_GuardDuty-red?style=flat-square)
- ![SecurityHub](https://img.shields.io/badge/AWS_Security_Hub-darkred?style=flat-square)
- ![Config](https://img.shields.io/badge/AWS_Config-blue?style=flat-square)
- ![Athena](https://img.shields.io/badge/AWS_Athena-purple?style=flat-square)
- ![S3](https://img.shields.io/badge/Amazon_S3-green?style=flat-square)
- ![EventBridge](https://img.shields.io/badge/Amazon_EventBridge-pink?style=flat-square)
- ![SNS](https://img.shields.io/badge/Amazon_SNS-lightgrey?style=flat-square)
- ![Lambda](https://img.shields.io/badge/AWS_Lambda-orange?style=flat-square)

### Tools & Platforms
- ![Terraform](https://img.shields.io/badge/Terraform-5835CC?style=flat-square&logo=terraform&logoColor=white)
- ![Datadog](https://img.shields.io/badge/Datadog-632CA6?style=flat-square&logo=datadog&logoColor=white)

---

## 🚀 Getting Started

### 📋 Prerequisites
- [Terraform](https://developer.hashicorp.com/terraform/downloads) (v1.0+)
- [AWS CLI](https://aws.amazon.com/cli/) configured
- Datadog API Key & Application Key

### ⚙️ Installation & Deployment

1. **Clone the Project**
   ```bash
   git clone https://github.com/grandeemir/aws-security-monitoring.git
   cd aws-security-monitoring
   ```

2. **Initialize Terraform**
   ```bash
   cd environment/dev
   terraform init
   ```

3. **Deploy Infrastructure**
   ```bash
   terraform plan
   terraform apply
   ```

---

## 📂 Project Structure

```text
├── modules/
│   ├── s3/            # Secure logging buckets
│   ├── cloudtrail/    # Audit logging
│   ├── guardduty/     # Threat intelligence
│   ├── datadog/       # SIEM integration
│   ├── athena/        # SQL log analysis
│   └── security_hub/  # Compliance dashboard
└── environment/
    └── dev/           # Development environment settings
```

---

## 🤝 Contributing
1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

<p align="center">
  Built with ❤️ for a safer cloud.
</p>
