<script setup>
import { onMounted, onUnmounted, ref } from 'vue';

const canvas = ref(null);
let ctx = null;
let animationFrameId = null;
let particles = [];

class Particle {
  constructor(width, height) {
    this.x = Math.random() * width;
    this.y = Math.random() * height;
    this.size = Math.random() * 3 + 1;
    this.speedX = (Math.random() - 0.5) * 1;
    this.speedY = (Math.random() - 0.5) * 1;
    this.opacity = Math.random() * 0.5 + 0.2;
    this.color = this.getRandomColor();
  }

  getRandomColor() {
    const colors = [
      'rgba(147, 51, 234, ', // Purple
      'rgba(59, 130, 246, ', // Blue
      'rgba(236, 72, 153, ', // Pink
      'rgba(255, 255, 255, ', // White
    ];
    return colors[Math.floor(Math.random() * colors.length)];
  }

  update(width, height) {
    this.x += this.speedX;
    this.y += this.speedY;

    // Wrap around screen
    if (this.x < 0) this.x = width;
    if (this.x > width) this.x = 0;
    if (this.y < 0) this.y = height;
    if (this.y > height) this.y = 0;

    // Pulse effect
    this.opacity += Math.sin(Date.now() * 0.001) * 0.005;
    this.opacity = Math.max(0.1, Math.min(0.7, this.opacity));
  }

  draw(context) {
    context.save();
    context.globalAlpha = this.opacity;
    context.fillStyle = this.color + this.opacity + ')';
    context.beginPath();
    context.arc(this.x, this.y, this.size, 0, Math.PI * 2);
    context.fill();

    // Glow effect
    context.shadowBlur = 10;
    context.shadowColor = this.color + '0.5)';
    context.fill();

    context.restore();
  }
}

function createParticles(width, height) {
  particles = [];
  const particleCount = Math.floor((width * height) / 10000);
  for (let i = 0; i < particleCount; i++) {
    particles.push(new Particle(width, height));
  }
}

function animate() {
  if (!ctx || !canvas.value) return;

  const width = canvas.value.width;
  const height = canvas.value.height;

  // Clear canvas with slight trail effect
  ctx.fillStyle = 'rgba(0, 0, 0, 0.05)';
  ctx.fillRect(0, 0, width, height);

  // Update and draw particles
  particles.forEach(particle => {
    particle.update(width, height);
    particle.draw(ctx);
  });

  animationFrameId = requestAnimationFrame(animate);
}

function handleResize() {
  if (!canvas.value) return;

  canvas.value.width = window.innerWidth;
  canvas.value.height = window.innerHeight;

  createParticles(canvas.value.width, canvas.value.height);
}

onMounted(() => {
  if (!canvas.value) return;

  ctx = canvas.value.getContext('2d');
  canvas.value.width = window.innerWidth;
  canvas.value.height = window.innerHeight;

  createParticles(canvas.value.width, canvas.value.height);

  window.addEventListener('resize', handleResize);

  animate();
});

onUnmounted(() => {
  if (animationFrameId) {
    cancelAnimationFrame(animationFrameId);
  }
  window.removeEventListener('resize', handleResize);
});
</script>

<template>
  <canvas ref="canvas" class="fixed inset-0 z-0 pointer-events-none"></canvas>
</template>
