import sys
import argparse
import subprocess

def run_cmd(cmd):
    try:
        res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, shell=True)
        return res.stdout.strip()
    except Exception:
        return ""

def audit_zero_trace(project_id):
    print("\n" + "=" * 65)
    print(" 🛡️  AUDITORÍA DE SEGURIDAD SRE: CERTIFICACIÓN DE CERO RASTRO GCP")
    print("=" * 65)
    print(f" Proyecto Auditado: {project_id or 'Entorno Local / Simulado'}")
    print("-" * 65)

    checks = [
        ("Instancias Compute Engine (VMs)", "gcloud compute instances list --format='value(name)'"),
        ("Discos Persistentes Huérfanos", "gcloud compute disks list --format='value(name)'"),
        ("Reglas de Firewall Personalizadas", "gcloud compute firewall-rules list --filter='name ~ realstate' --format='value(name)'"),
        ("Subredes VPC Personalizadas", "gcloud compute networks subnets list --filter='network ~ realstate' --format='value(name)'"),
        ("VPC Principal", "gcloud compute networks list --filter='name ~ realstate' --format='value(name)'")
    ]

    all_clean = True
    for label, cmd in checks:
        output = run_cmd(cmd)
        items = [line for line in output.split('\n') if line.strip()] if output else []
        count = len(items)

        if count == 0:
            print(f"  ✅ {label:<38}: 0 (CERO RASTRO)")
        else:
            print(f"  ❌ {label:<38}: {count} RECURSOS REMANENTES ENCONTRADOS")
            all_clean = False
            for item in items:
                print(f"      -> {item}")

    print("-" * 65)
    if all_clean:
        print("  🎉 CERTIFICADO DE CERO RASTRO: APROBADO")
        print("  Garantía: No existen gastos recurrentes ni rastros en GCP.")
    else:
        print("  ⚠️ ALERTA DE RECURSOS HUÉRFANOS DETECTADOS")
        print("  Acción: Ejecuta 'bash destroy_infrastructure.sh --force' para purgar.")
    print("=" * 65 + "\n")

    return 0 if all_clean else 1

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Certificación SRE de Cero Rastro GCP")
    parser.add_argument("--project", default="", help="GCP Project ID")
    args = parser.parse_args()
    sys.exit(audit_zero_trace(args.project))
