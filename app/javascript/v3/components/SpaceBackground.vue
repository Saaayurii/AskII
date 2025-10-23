<script setup>
import { onMounted, onUnmounted, ref } from 'vue';

const canvas = ref(null);
let ctx = null;
let animationFrameId = null;
let stars = [];
let shootingStars = [];
let mouseX = 0;
let mouseY = 0;

class Star {
  constructor(width, height) {
    this.x = Math.random() * width;
    this.y = Math.random() * height;
    this.size = Math.random() * 2;
    this.speedX = (Math.random() - 0.5) * 0.2;
    this.speedY = (Math.random() - 0.5) * 0.2;
    this.opacity = Math.random() * 0.5 + 0.5;
    this.twinkleSpeed = Math.random() * 0.02 + 0.01;

    // Color variation (white, blue, yellow)
    const colorType = Math.random();
    if (colorType < 0.7) {
      this.color = { r: 255, g: 255, b: 255 }; // White
    } else if (colorType < 0.85) {
      this.color = { r: 150, g: 200, b: 255 }; // Blue
    } else {
      this.color = { r: 255, g: 230, b: 150 }; // Yellow
    }
  }

  update(width, height, mouseInfluence) {
    // Twinkle effect
    this.opacity += Math.sin(Date.now() * this.twinkleSpeed) * 0.01;
    this.opacity = Math.max(0.3, Math.min(1, this.opacity));

    // Mouse parallax effect
    this.x += this.speedX + mouseInfluence.x * this.size * 0.1;
    this.y += this.speedY + mouseInfluence.y * this.size * 0.1;

    // Wrap around screen
    if (this.x < 0) this.x = width;
    if (this.x > width) this.x = 0;
    if (this.y < 0) this.y = height;
    if (this.y > height) this.y = 0;
  }

  draw(context) {
    context.save();
    context.globalAlpha = this.opacity;
    context.fillStyle = `rgb(${this.color.r}, ${this.color.g}, ${this.color.b})`;
    context.beginPath();
    context.arc(this.x, this.y, this.size, 0, Math.PI * 2);
    context.fill();
    context.restore();
  }
}

class ShootingStar {
  constructor(width, height) {
    this.x = Math.random() * width;
    this.y = Math.random() * height * 0.5;
    this.length = Math.random() * 80 + 20;
    this.speed = Math.random() * 10 + 5;
    this.opacity = 1;
    this.angle = Math.PI / 4;
  }

  update() {
    this.x += Math.cos(this.angle) * this.speed;
    this.y += Math.sin(this.angle) * this.speed;
    this.opacity -= 0.01;
  }

  draw(context) {
    context.save();
    context.globalAlpha = this.opacity;
    context.strokeStyle = 'white';
    context.lineWidth = 2;
    context.beginPath();
    context.moveTo(this.x, this.y);
    context.lineTo(
      this.x - Math.cos(this.angle) * this.length,
      this.y - Math.sin(this.angle) * this.length
    );
    context.stroke();
    context.restore();
  }

  isDead() {
    return this.opacity <= 0;
  }
}

function createStars(width, height) {
  stars = [];
  const starCount = Math.floor((width * height) / 3000);
  for (let i = 0; i < starCount; i++) {
    stars.push(new Star(width, height));
  }
}

function createShootingStar(width, height) {
  if (Math.random() < 0.003) {
    // 0.3% chance each frame
    shootingStars.push(new ShootingStar(width, height));
  }
}

function drawGradient(context, width, height) {
  // Deep space gradient
  const gradient = context.createRadialGradient(
    width / 2,
    height / 2,
    0,
    width / 2,
    height / 2,
    Math.max(width, height)
  );
  gradient.addColorStop(0, '#0a0e27');
  gradient.addColorStop(0.5, '#0d1117');
  gradient.addColorStop(1, '#000000');

  context.fillStyle = gradient;
  context.fillRect(0, 0, width, height);
}

function drawNebula(context, width, height) {
  // Draw some nebula-like effects
  const nebulaCount = 3;
  for (let i = 0; i < nebulaCount; i++) {
    const x = (width / nebulaCount) * i + width / (nebulaCount * 2);
    const y = height / 2 + Math.sin(Date.now() * 0.0001 + i) * 100;
    const size = Math.min(width, height) * 0.4;

    const gradient = context.createRadialGradient(x, y, 0, x, y, size);

    // Random nebula colors
    const colors = [
      ['rgba(147, 51, 234, 0.03)', 'rgba(147, 51, 234, 0)'], // Purple
      ['rgba(59, 130, 246, 0.03)', 'rgba(59, 130, 246, 0)'], // Blue
      ['rgba(236, 72, 153, 0.03)', 'rgba(236, 72, 153, 0)'], // Pink
    ];

    const colorPair = colors[i % colors.length];
    gradient.addColorStop(0, colorPair[0]);
    gradient.addColorStop(1, colorPair[1]);

    context.fillStyle = gradient;
    context.fillRect(0, 0, width, height);
  }
}

function animate() {
  if (!ctx || !canvas.value) return;

  const width = canvas.value.width;
  const height = canvas.value.height;

  // Clear canvas
  drawGradient(ctx, width, height);
  drawNebula(ctx, width, height);

  // Mouse influence
  const mouseInfluence = {
    x: mouseX * 0.05,
    y: mouseY * 0.05,
  };

  // Update and draw stars
  stars.forEach(star => {
    star.update(width, height, mouseInfluence);
    star.draw(ctx);
  });

  // Create shooting stars randomly
  createShootingStar(width, height);

  // Update and draw shooting stars
  shootingStars = shootingStars.filter(star => {
    star.update();
    star.draw(ctx);
    return !star.isDead();
  });

  animationFrameId = requestAnimationFrame(animate);
}

function handleResize() {
  if (!canvas.value) return;

  canvas.value.width = window.innerWidth;
  canvas.value.height = window.innerHeight;

  createStars(canvas.value.width, canvas.value.height);
}

function handleMouseMove(e) {
  mouseX = (e.clientX / window.innerWidth) * 2 - 1;
  mouseY = (e.clientY / window.innerHeight) * 2 - 1;
}

onMounted(() => {
  if (!canvas.value) return;

  ctx = canvas.value.getContext('2d');
  canvas.value.width = window.innerWidth;
  canvas.value.height = window.innerHeight;

  createStars(canvas.value.width, canvas.value.height);

  window.addEventListener('resize', handleResize);
  window.addEventListener('mousemove', handleMouseMove);

  animate();
});

onUnmounted(() => {
  if (animationFrameId) {
    cancelAnimationFrame(animationFrameId);
  }
  window.removeEventListener('resize', handleResize);
  window.removeEventListener('mousemove', handleMouseMove);
});
</script>

<template>
  <canvas ref="canvas" class="fixed inset-0 z-0"></canvas>
</template>
