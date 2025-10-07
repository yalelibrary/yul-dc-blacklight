// Highlight UV caption when clicked
$(document).ready(function() {
  var highlightActive = false;
  var targetSelector = '#uv > div > div > div.mainPanel.leftPanelOpen.rightPanelOpen > div.rightPanel.open.open-finished > div.main > article > div.groups > div:nth-child(2) > div.items > div.item._image-_caption > div.values > div';
  
  function applyHighlight() {
    if (!highlightActive) return;
    
    var uvIframe = document.getElementById('uv-iframe');
    if (uvIframe && uvIframe.contentWindow) {
      try {
        var iframeDoc = uvIframe.contentWindow.document || uvIframe.contentDocument;
        var targetElement = iframeDoc.querySelector(targetSelector);
        
        if (targetElement) {
          // Apply the yellow background with !important
          targetElement.style.setProperty('background', 'yellow', 'important');
        }
      } catch (error) {
        console.error('Error accessing UV iframe:', error);
      }
    }
  }
  
  // Click handler
  $(document).on('click', 'a.highlight-uv-caption', function(e) {
    highlightActive = true;
    
    // Apply immediately
    applyHighlight();
    
    // Set up interval to reapply the style (in case UV re-renders)
    if (window.highlightInterval) {
      clearInterval(window.highlightInterval);
    }
    
    window.highlightInterval = setInterval(applyHighlight, 500);
  });
});

