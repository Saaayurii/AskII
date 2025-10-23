export default {
  mounted(el) {
    el.style.position = 'relative';
    el.style.overflow = 'hidden';

    const createRipple = event => {
      const button = event.currentTarget;
      const circle = document.createElement('span');
      const diameter = Math.max(button.clientWidth, button.clientHeight);
      const radius = diameter / 2;

      const rect = button.getBoundingClientRect();
      circle.style.width = circle.style.height = `${diameter}px`;
      circle.style.left = `${event.clientX - rect.left - radius}px`;
      circle.style.top = `${event.clientY - rect.top - radius}px`;
      circle.classList.add('ripple');

      const ripple = button.getElementsByClassName('ripple')[0];

      if (ripple) {
        ripple.remove();
      }

      button.appendChild(circle);
    };

    el.addEventListener('click', createRipple);

    // Store the listener so we can remove it later
    el._rippleClickHandler = createRipple;

    // Add CSS for ripple effect
    if (!document.getElementById('ripple-styles')) {
      const style = document.createElement('style');
      style.id = 'ripple-styles';
      style.textContent = `
        .ripple {
          position: absolute;
          border-radius: 50%;
          background: rgba(255, 255, 255, 0.6);
          transform: scale(0);
          animation: ripple-animation 600ms ease-out;
          pointer-events: none;
        }

        @keyframes ripple-animation {
          to {
            transform: scale(4);
            opacity: 0;
          }
        }
      `;
      document.head.appendChild(style);
    }
  },
  unmounted(el) {
    if (el._rippleClickHandler) {
      el.removeEventListener('click', el._rippleClickHandler);
      delete el._rippleClickHandler;
    }
  },
};
