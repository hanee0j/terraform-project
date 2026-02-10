# Terraform + Jenkins 기반 AWS EKS Monitoring 구축

본 프로젝트는 **AWS EKS 환경에서 과도하게 할당된 리소스(CPU / Memory)를 식별하고 Right-Sizing을 위한 기반을 마련하기 위해** 진행한 개인 프로젝트이다.

비용 효율성을 위해 **EKS 클러스터는 필요 시 생성(terraform apply)하고, 사용 종료 후 제거(terraform destroy)** 하는 구조로 설계하였으며, 이에 따라 **클러스터 내부 리소스는 Jenkins를 통해 자동으로 재구성**하도록 구성하였다.

---

## 프로젝트 목표
- Terraform 기반 EKS 인프라 구성 및 운영 경험
- Prometheus 메트릭을 활용한 실제 리소스 사용량 분석
- 리소스 과다 할당 워크로드 식별
- 향후 VPA(Vertical Pod Autoscaler) 연계를 통한 자동화 가능성 검증

---

## 아키텍처 개요
- **IaC**: Terraform
- **Container Orchestration**: Amazon EKS
- **Networking**: VPC (Public / Private Subnet 분리)
- **Observability**:
  - Prometheus: CPU / Memory 사용률 수집
  - Grafana: 리소스 사용 현황 시각화
- **Optimization**:
  - Vertical Pod Autoscaler(VPA)

---

## 디렉터리 구조
```
├── eks/
│   ├── main.tf                # EKS / VPC 주요 리소스 정의
│   ├── vars.tf                # 변수 선언
│   ├── outputs.tf             # 출력 값 정의
│   ├── backend.tf             # S3 + DynamoDB Terraform Backend
│   ├── terraform.tfvars       # 환경별 변수 (Git 제외)
│   └── .terraform.lock.hcl    # Provider 버전 고정
├── jenkins/
│   ├── Jenkinsfile.monitoring # Prometheus / Grafana 설치
│   ├── Jenkinsfile.app        # 샘플 애플리케이션 배포
│   └── Jenkinsfile.analysis   # 리소스 분석 파이프라인
└── README.md
```