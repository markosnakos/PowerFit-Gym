<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" encoding="UTF-8" indent="yes" doctype-system="about:legacy-compat"/>
  <xsl:strip-space elements="*"/>
  <xsl:preserve-space elements="description note paragraph item announcementBody"/>

  <!-- Indexes for record lookups and grouping. -->
  <xsl:key name="plans" match="plan" use="@id"/>
  <xsl:key name="trainers" match="trainer" use="@id"/>
  <xsl:key name="rooms" match="room" use="@id"/>
  <xsl:key name="classes" match="class" use="@id"/>
  <xsl:key name="members" match="member" use="@id"/>
  <xsl:key name="sessions-by-class" match="session" use="@classRef"/>
  <xsl:key name="plans-by-currency" match="plan" use="@currency"/>
  <xsl:key name="guides-by-resource" match="memberDesk/guides/guide" use="@resource"/>

  <xsl:template match="/gym">
    <html lang="en">
      <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <meta name="description" content="PowerFit Gym XML/XSLT management dashboard"/>
        <title><xsl:value-of select="name"/> | Management Dashboard</title>
        <link rel="stylesheet" href="style.css"/>
      </head>
      <body>
        <div class="site-shell">
          <header class="site-header">
            <a class="brand" href="#overview"><span class="brand-mark">PF</span><span><strong><xsl:value-of select="name"/></strong><small>Management Dashboard</small></span></a>
            <nav aria-label="Primary navigation">
              <a href="#overview">Overview</a><a href="#plans">Plans</a><a href="#classes">Classes</a><a href="#schedule">Schedule</a><a href="#trainers">Trainers</a><a href="#members">Members</a><a href="#rooms">Rooms</a>
              <xsl:if test="memberDesk"><a href="#member-desk">Member desk</a></xsl:if>
            </nav>
          </header>
          <main>
            <section class="hero" id="overview">
              <div>
                <p class="eyebrow">POWERFIT / MANAGEMENT SYSTEM <span class="dot">&#8226;</span> XML v<xsl:value-of select="@version"/></p>
                <h1>Move better.<br/><span>Manage smarter.</span></h1>
                <p class="hero-intro"><xsl:value-of select="tagline"/> Explore our members, instructors, membership plans and weekly class timetable in one place.</p>
                <div class="hero-actions"><a class="button" href="#schedule">Explore the schedule <span aria-hidden="true">&#8594;</span></a><a class="button button-outline" href="#classes">View classes</a></div>
              </div>
              <div class="hero-panel">
                <p class="panel-kicker">AT A GLANCE</p>
                <div class="hero-panel-total"><xsl:value-of select="count(members/member[@status='active'])"/><span>active members</span></div>
                <div class="panel-divider"></div>
                <p>Based in <strong><xsl:value-of select="location/city"/></strong></p>
                <p><xsl:value-of select="location/street"/><xsl:if test="location/postalCode">, <xsl:value-of select="location/postalCode"/></xsl:if></p>
                <xsl:if test="contact"><p><a href="mailto:{contact/email}"><xsl:value-of select="contact/email"/></a></p><xsl:if test="contact/phone"><p><xsl:value-of select="contact/phone"/></p></xsl:if></xsl:if>
              </div>
            </section>
            <section class="stats" aria-label="Gym statistics">
              <div class="stat"><span class="stat-value"><xsl:value-of select="count(members/member)"/></span><span class="stat-label">Total members</span></div>
              <div class="stat"><span class="stat-value"><xsl:value-of select="count(trainers/trainer)"/></span><span class="stat-label">Expert trainers</span></div>
              <div class="stat"><span class="stat-value"><xsl:value-of select="count(classes/class)"/></span><span class="stat-label">Fitness classes</span></div>
              <div class="stat"><span class="stat-value"><xsl:value-of select="count(schedule/session)"/></span><span class="stat-label">Weekly sessions</span></div>
            </section>

            <section class="section" id="plans">
              <div class="section-heading"><div><p class="eyebrow">FLEXIBLE OPTIONS</p><h2>Membership plans</h2></div><p>Choose the access level that fits your routine. All rates are shown per month.</p></div>
              <div class="plan-grid"><xsl:apply-templates select="membershipPlans/plan"/></div>
              <div class="insight">
                <span>Average monthly list price by currency:</span>
                <ul class="currency-averages">
                  <xsl:for-each select="membershipPlans/plan[generate-id() = generate-id(key('plans-by-currency', @currency)[1])]">
                    <xsl:sort select="@currency"/>
                    <xsl:variable name="currencyPlans" select="key('plans-by-currency', @currency)"/>
                    <li><strong><xsl:value-of select="@currency"/><xsl:text> </xsl:text><xsl:value-of select="format-number(sum($currencyPlans/monthlyPrice) div count($currencyPlans), '0.00')"/></strong></li>
                  </xsl:for-each>
                </ul>
              </div>
            </section>

            <section class="section" id="classes">
              <div class="section-heading"><div><p class="eyebrow">FIND YOUR WORKOUT</p><h2>Explore our classes</h2></div><p>Every class includes an assigned trainer, fitness level and equipment requirements.</p></div>
              <div class="class-grid"><xsl:apply-templates select="classes/class"><xsl:sort select="className"/></xsl:apply-templates></div>
            </section>

            <section class="section" id="schedule">
              <div class="section-heading"><div><p class="eyebrow">EVERY WEEK</p><h2>Class timetable</h2></div><p>Sessions are displayed in weekday and start-time order, with participant names resolved from member IDs.</p></div>
              <div class="table-scroll"><table class="data-table schedule-table"><thead><tr><th>Day / time</th><th>Class &amp; trainer</th><th>Room</th><th>Registrations</th><th>Details</th></tr></thead><tbody>
                <xsl:apply-templates select="schedule/session">
                  <xsl:sort data-type="number" select="string-length(substring-before('Monday Tuesday Wednesday Thursday Friday Saturday Sunday', @day))"/>
                  <xsl:sort select="startTime"/>
                </xsl:apply-templates>
              </tbody></table></div>
            </section>

            <section class="section" id="trainers">
              <div class="section-heading"><div><p class="eyebrow">MEET THE TEAM</p><h2>Our trainers</h2></div><p>Professional specialties, employment types, certifications and contact information.</p></div>
              <div class="trainer-grid"><xsl:apply-templates select="trainers/trainer"><xsl:sort select="fullName"/></xsl:apply-templates></div>
            </section>

            <section class="section" id="members">
              <div class="section-heading"><div><p class="eyebrow">MEMBER DIRECTORY</p><h2>Members &amp; subscriptions</h2></div><p><xsl:value-of select="count(members/member[@status='active'])"/> active, <xsl:value-of select="count(members/member[@status='paused'])"/> paused, and <xsl:value-of select="count(members/member[@status='cancelled'])"/> cancelled memberships.</p></div>
              <div class="table-scroll"><table class="data-table"><thead><tr><th>Member</th><th>Age / joined</th><th>Membership</th><th>Status</th><th>Contact</th><th>Emergency contact</th></tr></thead><tbody><xsl:apply-templates select="members/member"><xsl:sort select="fullName"/></xsl:apply-templates></tbody></table></div>
            </section>

            <section class="section" id="rooms">
              <div class="section-heading"><div><p class="eyebrow">THE SPACE</p><h2>Facilities &amp; rooms</h2></div><p><xsl:value-of select="count(rooms/room)"/> training spaces with a combined capacity of <xsl:value-of select="sum(rooms/room/capacity)"/> people (room capacities, not simultaneous gym occupancy).</p></div>
              <div class="room-grid"><xsl:apply-templates select="rooms/room"/></div>
            </section>

            <xsl:apply-templates select="memberDesk"/>
          </main>
          <footer class="footer"><div><strong><xsl:value-of select="name"/></strong><span><xsl:value-of select="tagline"/></span></div><p>XML 1.0 &#8226; DTD &#8226; XSLT 1.0 &#8226; HTML / CSS</p><a href="#overview">Back to top &#8593;</a></footer>
        </div>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="memberDesk">
    <section class="section" id="member-desk">
      <div class="section-heading">
        <div><p class="eyebrow">BEFORE YOUR VISIT</p><h2>Member desk</h2></div>
        <p>Announcements from reception and practical guides for your next visit.</p>
      </div>
      <div class="announcement-grid"><xsl:apply-templates select="announcements/announcement"/></div>
      <div class="desk-guides">
        <h3>Guides to keep handy</h3>
        <div class="download-grid"><xsl:apply-templates select="guides/guide"/></div>
      </div>
    </section>
  </xsl:template>

  <xsl:template match="announcement">
    <article class="announcement-card" id="{@id}" aria-labelledby="{@id}-title">
      <h3 id="{@id}-title"><xsl:value-of select="announcementTitle"/></h3>
      <div class="announcement-body"><xsl:apply-templates select="announcementBody/node()" mode="rich-text"/></div>
      <xsl:if test="@attachments">
        <div class="announcement-guides">
          <h4>Related guides</h4>
          <ul><xsl:call-template name="guide-links"><xsl:with-param name="refs" select="@attachments"/></xsl:call-template></ul>
        </div>
      </xsl:if>
    </article>
  </xsl:template>

  <xsl:template name="guide-links">
    <xsl:param name="refs"/>
    <xsl:variable name="clean" select="normalize-space($refs)"/>
    <xsl:if test="$clean != ''">
      <xsl:variable name="first" select="substring-before(concat($clean, ' '), ' ')"/>
      <xsl:variable name="remaining" select="substring-after($clean, ' ')"/>
      <xsl:variable name="guide" select="key('guides-by-resource', $first)[1]"/>
      <xsl:if test="$guide">
        <li><a class="record-link" href="#{$guide/@id}"><xsl:value-of select="$guide/guideTitle"/></a></li>
      </xsl:if>
      <xsl:call-template name="guide-links"><xsl:with-param name="refs" select="$remaining"/></xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="guide">
    <article class="download-card" id="{@id}" aria-labelledby="{@id}-title">
      <h3 id="{@id}-title"><xsl:value-of select="guideTitle"/></h3>
      <xsl:if test="guideDescription"><p><xsl:value-of select="guideDescription"/></p></xsl:if>
      <a class="resource-link">
        <xsl:attribute name="type"><xsl:choose><xsl:when test="@format='plainText'">text/plain</xsl:when><xsl:otherwise>application/octet-stream</xsl:otherwise></xsl:choose></xsl:attribute>
        <xsl:attribute name="href"><xsl:call-template name="resource-href"><xsl:with-param name="uri" select="translate(unparsed-entity-uri(@resource), '&#92;', '/')"/></xsl:call-template></xsl:attribute>
        <xsl:attribute name="aria-label">Open <xsl:value-of select="guideTitle"/></xsl:attribute>
        <xsl:text>Open guide</xsl:text><xsl:if test="@format='plainText'"><xsl:text> (.txt)</xsl:text></xsl:if><xsl:text> </xsl:text><span aria-hidden="true">&#8594;</span>
      </a>
    </article>
  </xsl:template>

  <!-- Keep local resource URLs portable when processors expand entity URIs to file paths. -->
  <xsl:template name="resource-href">
    <xsl:param name="uri"/>
    <xsl:choose>
      <xsl:when test="contains($uri, '/resources/') and (starts-with($uri, 'file:') or not(contains($uri, '://')))">
        <xsl:text>resources/</xsl:text><xsl:value-of select="substring-after($uri, '/resources/')"/>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$uri"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Rich-text elements shared by descriptions, notes, and announcements. -->
  <xsl:template match="paragraph" mode="rich-text">
    <p><xsl:apply-templates mode="rich-text"/></p>
  </xsl:template>

  <xsl:template match="strong" mode="rich-text">
    <strong><xsl:apply-templates mode="rich-text"/></strong>
  </xsl:template>

  <xsl:template match="em" mode="rich-text">
    <em><xsl:apply-templates mode="rich-text"/></em>
  </xsl:template>

  <xsl:template match="checklist" mode="rich-text">
    <ul><xsl:apply-templates select="item" mode="rich-text"/></ul>
  </xsl:template>

  <xsl:template match="item" mode="rich-text">
    <li><xsl:apply-templates mode="rich-text"/></li>
  </xsl:template>

  <xsl:template match="plan">
    <article class="plan-card" id="{@id}">
      <div class="card-top"><span class="tag"><xsl:value-of select="@accessLevel"/> access</span><xsl:if test="@accessLevel='all'"><span class="featured-tag">MOST FLEXIBLE</span></xsl:if></div>
      <h3><a class="record-link" href="#{@id}"><xsl:value-of select="planName"/></a></h3>
      <p class="plan-price"><xsl:choose><xsl:when test="@currency='EUR'">&#8364;</xsl:when><xsl:when test="@currency='USD'">$</xsl:when><xsl:otherwise>&#163;</xsl:otherwise></xsl:choose><xsl:value-of select="format-number(number(monthlyPrice), '0.00')"/><span> / <xsl:value-of select="monthlyPrice/@billingPeriod"/></span></p>
      <ul class="feature-list"><xsl:for-each select="features/*"><li><xsl:attribute name="class"><xsl:choose><xsl:when test="self::limitation">limit</xsl:when><xsl:otherwise>included</xsl:otherwise></xsl:choose></xsl:attribute><span><xsl:choose><xsl:when test="self::limitation">&#8211;</xsl:when><xsl:otherwise>&#10003;</xsl:otherwise></xsl:choose></span><xsl:value-of select="."/></li></xsl:for-each></ul>
      <div class="card-meta">Plan ID: <code><xsl:value-of select="@id"/></code></div>
    </article>
  </xsl:template>

  <xsl:template match="class">
    <article class="class-card" id="{@id}">
      <div class="card-top"><span class="tag"><xsl:value-of select="@category"/></span><span class="level level-{@level}"><xsl:value-of select="@level"/></span></div>
      <h3><a class="record-link" href="#{@id}"><xsl:value-of select="className"/></a></h3><p class="body-copy"><xsl:apply-templates select="description/node()" mode="rich-text"/></p>
      <xsl:if test="@tags"><p class="class-tags"><strong>Tags:</strong><xsl:text> </xsl:text><xsl:value-of select="@tags"/></p></xsl:if>
      <div class="detail-row"><span>Duration</span><strong><xsl:value-of select="durationMinutes"/><xsl:text> </xsl:text><xsl:value-of select="durationMinutes/@unit"/></strong></div>
      <div class="detail-row"><span>Trainer</span><strong><a class="record-link" href="#{@trainerRef}"><xsl:value-of select="key('trainers', @trainerRef)/fullName"/></a></strong></div>
      <div class="detail-row"><span>Sessions / week</span><strong><xsl:value-of select="count(key('sessions-by-class', @id))"/></strong></div>
      <div class="equipment"><strong>Equipment</strong><xsl:choose><xsl:when test="equipment"><ul><xsl:for-each select="equipment"><li><xsl:value-of select="."/></li></xsl:for-each></ul></xsl:when><xsl:otherwise><p>No special equipment listed.</p></xsl:otherwise></xsl:choose></div>
      <p class="idline">Class ID: <xsl:value-of select="@id"/></p>
    </article>
  </xsl:template>

  <!-- Resolve member references in registration order. -->
  <xsl:template name="member-names">
    <xsl:param name="refs"/>
    <xsl:variable name="clean" select="normalize-space($refs)"/>
    <xsl:if test="string-length($clean) &gt; 0">
      <xsl:variable name="first" select="substring-before(concat($clean, ' '), ' ')"/>
      <xsl:variable name="remaining" select="substring-after($clean, ' ')"/>
      <xsl:choose><xsl:when test="key('members', $first)"><a class="record-link" href="#{$first}"><xsl:value-of select="key('members', $first)/fullName"/></a></xsl:when><xsl:otherwise><xsl:value-of select="$first"/></xsl:otherwise></xsl:choose>
      <xsl:if test="string-length($remaining) &gt; 0"><xsl:text>, </xsl:text><xsl:call-template name="member-names"><xsl:with-param name="refs" select="$remaining"/></xsl:call-template></xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="session">
    <xsl:variable name="linkedClass" select="key('classes', @classRef)"/>
    <xsl:variable name="linkedRoom" select="key('rooms', @roomRef)"/>
    <xsl:variable name="refs" select="normalize-space(registrations/@memberRefs)"/>
    <xsl:variable name="registrationsCount" select="number(boolean(string-length($refs))) * (string-length($refs) - string-length(translate($refs, ' ', '')) + 1)"/>
    <tr id="{@id}">
      <td><strong><xsl:value-of select="@day"/></strong><span class="table-muted"><xsl:value-of select="startTime"/>–<xsl:value-of select="endTime"/></span></td>
      <td><strong><a class="record-link" href="#{@classRef}"><xsl:value-of select="$linkedClass/className"/></a></strong><span class="table-muted"><a class="record-link" href="#{$linkedClass/@trainerRef}"><xsl:value-of select="key('trainers', $linkedClass/@trainerRef)/fullName"/></a></span></td>
      <td><strong><a class="record-link" href="#{@roomRef}"><xsl:value-of select="$linkedRoom/roomName"/></a></strong><span class="table-muted"><xsl:value-of select="$linkedRoom/@type"/></span></td>
      <td><span class="count-badge"><xsl:value-of select="$registrationsCount"/> / <xsl:value-of select="$linkedRoom/capacity"/></span><xsl:choose><xsl:when test="$refs != ''"><span class="table-muted"><xsl:call-template name="member-names"><xsl:with-param name="refs" select="$refs"/></xsl:call-template></span></xsl:when><xsl:otherwise><span class="table-muted">No registered members</span></xsl:otherwise></xsl:choose></td>
      <td><span class="idline"><xsl:value-of select="@id"/></span><xsl:if test="note"><span class="table-muted"><xsl:apply-templates select="note/node()" mode="rich-text"/></span></xsl:if></td>
    </tr>
  </xsl:template>

  <xsl:template match="trainer">
    <article class="trainer-card" id="{@id}"><div class="trainer-top"><span class="avatar"><xsl:value-of select="substring(fullName, 1, 1)"/></span><span class="tag"><xsl:value-of select="@employment"/></span></div>
      <h3><a class="record-link" href="#{@id}"><xsl:value-of select="fullName"/></a></h3><p class="accent-text"><xsl:value-of select="specialty"/></p>
      <p><a href="mailto:{email}"><xsl:value-of select="email"/></a></p><xsl:if test="phone"><p><xsl:value-of select="phone"/></p></xsl:if>
      <div class="equipment"><strong>Certifications</strong><xsl:choose><xsl:when test="certification"><ul><xsl:for-each select="certification"><li><xsl:value-of select="."/></li></xsl:for-each></ul></xsl:when><xsl:otherwise><p>No certifications listed.</p></xsl:otherwise></xsl:choose></div>
      <p class="idline">Trainer ID: <xsl:value-of select="@id"/></p>
    </article>
  </xsl:template>

  <xsl:template match="member">
    <tr id="{@id}"><td><strong><a class="record-link" href="#{@id}"><xsl:value-of select="fullName"/></a></strong><span class="table-muted idline"><xsl:value-of select="@id"/></span></td>
      <td><strong><xsl:value-of select="age"/> years</strong><span class="table-muted">Joined <xsl:value-of select="joinedOn"/></span></td>
      <td><strong><a class="record-link" href="#{@planRef}"><xsl:value-of select="key('plans', @planRef)/planName"/></a></strong><span class="table-muted"><xsl:value-of select="@planRef"/></span></td>
      <td><span class="status status-{@status}"><xsl:value-of select="@status"/></span></td>
      <td><a href="mailto:{email}"><xsl:value-of select="email"/></a><xsl:if test="phone"><span class="table-muted"><xsl:value-of select="phone"/></span></xsl:if></td>
      <td><xsl:choose><xsl:when test="emergencyContact"><strong><xsl:value-of select="emergencyContact/fullName"/></strong><span class="table-muted"><xsl:value-of select="emergencyContact/phone | emergencyContact/email"/></span></xsl:when><xsl:otherwise><span class="table-muted">Not provided</span></xsl:otherwise></xsl:choose></td>
    </tr>
  </xsl:template>

  <xsl:template match="room">
    <article class="room-card" id="{@id}"><div class="card-top"><span class="tag"><xsl:value-of select="@type"/></span><span class="idline"><xsl:value-of select="@id"/></span></div>
      <h3><a class="record-link" href="#{@id}"><xsl:value-of select="roomName"/></a></h3>
      <xsl:if test="@code"><p class="idline">Room code: <xsl:value-of select="@code"/></p></xsl:if>
      <p class="room-capacity"><xsl:value-of select="capacity"/><span> person capacity</span></p>
      <div class="equipment"><strong>Amenities</strong><xsl:choose><xsl:when test="amenities/amenity"><ul><xsl:for-each select="amenities/amenity"><li><xsl:value-of select="."/></li></xsl:for-each></ul></xsl:when><xsl:otherwise><p>No additional amenities listed.</p></xsl:otherwise></xsl:choose></div>
    </article>
  </xsl:template>
</xsl:stylesheet>
