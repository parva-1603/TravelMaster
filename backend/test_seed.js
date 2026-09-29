const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  try {
    const dummyLocations = [
      { name: 'Delhi', state: 'Delhi' },
      { name: 'Mumbai', state: 'Maharashtra' },
      { name: 'Bangalore', state: 'Karnataka' },
      { name: 'Kerala', state: 'Kerala' },
      { name: 'Goa', state: 'Goa' },
      { name: 'Jaipur', state: 'Rajasthan' },
      { name: 'Ladakh', state: 'Ladakh' }
    ];
    await prisma.location.createMany({ data: dummyLocations });
    console.log("Created locations");
  } catch (e) {
    console.error("Error seeding:", e);
  } finally {
    await prisma.$disconnect();
  }
}
main();
