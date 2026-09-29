const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const packages = await prisma.package.findMany();
  console.log("Total packages in DB:", packages.length);
  console.log(packages);
}
main().finally(() => prisma.$disconnect());
