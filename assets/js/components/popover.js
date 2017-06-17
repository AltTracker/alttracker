const popoverLinks = document.querySelectorAll('[data-popover]')
const popovers = document.querySelectorAll('.popover')

function onPopoverLinkClick (e) {
  e.preventDefault()
  const hrefs = document.querySelector(this.dataset.popover)
  const popoverOpen = hrefs.classList.contains('popover-open')

  if (popoverOpen) {
    hrefs.classList.remove('popover-open')
  } else {
    console.log('add')
    closePopovers()
    hrefs.classList.add('popover-open')

    e.stopImmediatePropagation()
  }
}

function closePopovers () {
  popovers.forEach(l => l.classList.remove('popover-open'))
}

popoverLinks.forEach(l => l.addEventListener('click', onPopoverLinkClick))
document.addEventListener('click', closePopovers)
