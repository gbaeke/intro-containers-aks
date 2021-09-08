# Ingress

You can use services of type LoadBalancer for your applications but that poses some problems:
- secure traffic: if you want your pods to offer https, you will need to configure this at the pod level; to reduce management overhead and as a general best practice, this should be avoided
- traffic inspection: an Azure Load Balancer does not inspect traffic (e.g. web application firewalling)
- multitude of external IPs

With an **Ingress Controller** we can tackle some of the above problems. An **Ingress Controller** is software running in Kubernetes that watches for objects of type **Ingress**. These objects define how incoming requests to a **reverse proxy** should be handled and mapped to internal services. The **Ingress Controller** then configures the reverse proxy accordingly.

The **Ingress Controller** and **reverse proxy** are often both running in the Kubernetes cluster but that does not have to be the case. The **Ingress Controller** can run in the cluster and the **reverse proxy** can run outside the cluster. This is the case when you use **Azure Application Gateway** as your Kubernetes ingress solution:

![agic](agic.png)

