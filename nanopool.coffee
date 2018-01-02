command: ""

refreshFrequency: 30000 #ms

style: """
  bottom: 0px
  left: 20px
  color: #fff
  font-family: "Helvetica Neue", Helvetica, Arial, sans-serif

  a
    color: #FFF
    decoration: none

  .container
    background-color: rgba(#000, 0.2)
    border-radius: 20px 20px 0px 0px
    padding: 10px

  table 
    border: 0px solid
    border-spacing: 0
    border-collapse: collapse
    -webkit-font-smoothing: antialiased
    //-moz-osx-font-smoothing: grayscale

  .smallHead
    font-weight: 200
    display: block
    position: relative
    left: 0
    font-size: 16px
  
  td
    font-size: 40px
    //font-weight: 200
    overflow: hidden
    text-shadow: 0 0 1px rgba(#000, 0.5)
    //border: 1px solid

  .small
    font-size: 24px
    padding-right: 15px

  .hashrow
    //font-weight: 200
    padding-top: 15px
    padding-bottom: 15px
  
  .unit
    font-size: 15px

  hr
    background-color: rgba(#FFF, 0.7)
    border: 0 none
    color: #FFF
    height: 1px
  
  .meter 
    height: 16px;  /* Can be anything */
    min-width: 290px
    max-width: 500px
    position: relative
    background-color: rgba(#FFF, 0.2)
    border-radius: 20px
    padding: 4px
    box-shadow: inset 0 -1px 1px rgba(255,255,255,0.4)
    margin-top: 6px

  #percentValue
    display: block
    width: 100%
    position: absolute
    text-align: center
    top: 2px
    z-index: 10
    font-size: 14px
    font-weight: 200

  .meter .bar 
    z-index: 2
    display: block
    height: 100%
    font-size: 14px
    text-align: center
    border-radius: 16px
    background-color: rgba(#e95420, 1)
    //e95420
    background-image: linear-gradient(
      center bottom,
      rgb(43,194,83) 37%,
      rgb(84,240,84) 69%
    )
    box-shadow: 
      inset 0 2px 9px  rgba(255,255,255,0.3),
      inset 0 -2px 6px rgba(0,0,0,0.4)
    position: relative
    overflow: hidden
"""


update: (output, domEl) ->
  $domEl = $(domEl)

  account = "0x49562aeb4ae361fe150ca4d26c97e2248d174d20"
  payoutSetting = 0.05
  
  barLinkSrc = 'https://eth.nanopool.org/account/' + account
  $domEl.find('#barLink').attr("href", barLinkSrc)

  $.ajax({
    url: "https://api.nanopool.org/v1/eth/user/" + account,
    type: 'GET',
    success: (res) -> #in case there is a valid internet connection and JSON request is succesfull
      hashrate = res.data.hashrate
      hashrate6h = res.data.avgHashrate.h6
      balance = res.data.balance
      payoutPercent = Math.round(res.data.balance/payoutSetting*100*10)/10
      if payoutPercent > 100
        payoutPercent = 100

      $domEl.find('#hashrate').text "#{hashrate}"
      $domEl.find('#hashrate6h').text "#{hashrate6h}"
      $domEl.find('.meter').html "<span class='bar' style='width: #{payoutPercent}%'></span><span id='percentValue'>#{payoutPercent}%</span>"
      $.ajax({
        url: "https://v2.ethereumprice.org:8080/snapshot/eth/eur/waex/1h",
        type: 'GET',
        success: (res) -> #in case there is a valid internet connection and JSON request is succesfull
          $domEl.find('#sumSincePayout').text Math.round(res.data.price*balance*100)/100
          $domEl.find('#price').text res.data.price
          $domEl.find('#change').text '('+res.data.percent_change+'%)'
        error: (res) ->
      })
    error: (res) ->
     
  })

  $.ajax({
    url: "https://api.nanopool.org/v1/eth/reportedhashrate/" + account,
    type: 'GET',
    success: (res) -> #in case there is a valid internet connection and JSON request is succesfull
      $domEl.find('#reportedHashrate').text Math.round(res.data*10)/10
    error: (res) ->
  })

render: (o) -> """

  <div class="container">
    <table>

      <tr>
        <td colspan='3'>
          <span class='smallHead'>Ethereum</span>
          <span id='price'>0</span>€ <span class='unit' id='change'></span>
        </td>
      </tr>

      <tr>
        <td class='small hashrow'>
          <span class='smallHead'>Calculated</span>
          <span id='hashrate'></span><span class='unit'>MH/s</span>
        </td>
        <td class='small hashrow'>
          <span class='smallHead'>Reported</span>
          <span id='reportedHashrate'></span><span class='unit'>MH/s</span>
        </td>
        <td class='small hashrow'>
          <span class='smallHead'>Average</span>
          <span id='hashrate6h'></span><span class='unit'>MH/s</span>
        </td>
      </tr>

      <tr>
        <td colspan='3'>
          <span class='smallHead'>Earnings since payout</span>
          <span id='sumSincePayout'></span>€
        </td>
      </tr>

      <tr>
        <td colspan='3'>
          <span class='smallHead'>Until payout</span>
          <a id='barLink'>
            <div class="meter"></div>
          </a>
        </td>
      </tr>

    </table>
  </div>
"""