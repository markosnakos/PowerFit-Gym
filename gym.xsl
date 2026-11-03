<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" encoding="UTF-8" indent="yes" doctype-system="about:legacy-compat"/>
  <xsl:strip-space elements="*"/>

  <!-- These keys implement relational lookups between ID/IDREF attributes. -->
  <xsl:key name="plans" match="plan" use="@id"/>
  <xsl:key name="trainers" match="trainer" use="@id"/>
  <xsl:key name="rooms" match="room" use="@id"/>
  <xsl:key name="classes" match="class" use="@id"/>
  <xsl:key name="members" match="member" use="@id"/>
  <xsl:key name="sessions-by-class" match="session" use="@classRef"/>

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
              <div class="insight">Average monthly list price: <strong><xsl:value-of select="membershipPlans/plan[1]/@currency"/><xsl:text> </xsl:text><xsl:value-of select="format-number(sum(membershipPlans/plan/monthlyPrice) div count(membershipPlans/plan), '0.00')"/></strong></div>
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
              <p class="footnote">Directory entries are fictional demonstration data. A real-world system should protect personal and emergency contact details through access controls.</p>
            </section>

            <section class="section" id="rooms">
              <div class="section-heading"><div><p class="eyebrow">THE SPACE</p><h2>Facilities &amp; rooms</h2></div><p><xsl:value-of select="count(rooms/room)"/> training spaces with a combined capacity of <xsl:value-of select="sum(rooms/room/capacity)"/> people (room capacities, not simultaneous gym occupancy).</p></div>
              <div class="room-grid"><xsl:apply-templates select="rooms/room"/></div>
            </section>
          </main>
          <footer class="footer"><div><strong><xsl:value-of select="name"/></strong><span><xsl:value-of select="tagline"/></span></div><p>XML 1.0 &#8226; DTD &#8226; XSLT 1.0 &#8226; HTML / CSS</p><a href="#overview">Back to top &#8593;</a></footer>
        </div>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="plan">
    <article class="plan-card">
      <div class="card-top"><span class="tag"><xsl:value-of select="@accessLevel"/> access</span><xsl:if test="@accessLevel='all'"><span class="featured-tag">MOST FLEXIBLE</span></xsl:if></div>
      <h3><xsl:value-of select="planName"/></h3>
      <p class="plan-price"><xsl:choose><xsl:when test="@currency='EUR'">&#8364;</xsl:when><xsl:when test="@currency='USD'">$</xsl:when><xsl:otherwise>&#163;</xsl:otherwise></xsl:choose><xsl:value-of select="format-number(number(monthlyPrice), '0.00')"/><span> / <xsl:value-of select="monthlyPrice/@billingPeriod"/></span></p>
      <ul class="feature-list"><xsl:for-each select="features/*"><li><xsl:attribute name="class"><xsl:choose><xsl:when test="self::limitation">limit</xsl:when><xsl:otherwise>included</xsl:otherwise></xsl:choose></xsl:attribute><span><xsl:choose><xsl:when test="self::limitation">&#8211;</xsl:when><xsl:otherwise>&#10003;</xsl:otherwise></xsl:choose></span><xsl:value-of select="."/></li></xsl:for-each></ul>
      <div class="card-meta">Plan ID: <code><xsl:value-of select="@id"/></code></div>
    </article>
  </xsl:template>

  <xsl:template match="class">
    <article class="class-card">
      <div class="card-top"><span class="tag"><xsl:value-of select="@category"/></span><span class="level level-{@level}"><xsl:value-of select="@level"/></span></div>
      <h3><xsl:value-of select="className"/></h3><p class="body-copy"><xsl:value-of select="description"/></p>
      <div class="detail-row"><span>Duration</span><strong><xsl:value-of select="durationMinutes"/> <xsl:value-of select="durationMinutes/@unit"/></strong></div>
      <div class="detail-row"><span>Trainer</span><strong><xsl:value-of select="key('trainers', @trainerRef)/fullName"/></strong></div>
      <div class="detail-row"><span>Sessions / week</span><strong><xsl:value-of select="count(key('sessions-by-class', @id))"/></strong></div>
      <div class="equipment"><strong>Equipment</strong><xsl:choose><xsl:when test="equipment"><ul><xsl:for-each select="equipment"><li><xsl:value-of select="."/></li></xsl:for-each></ul></xsl:when><xsl:otherwise><p>No special equipment listed.</p></xsl:otherwise></xsl:choose></div>
      <p class="idline">Class ID: <xsl:value-of select="@id"/></p>
    </article>
  </xsl:template>

  <!-- Recursive tokenizer for DTD IDREFS, compatible with XSLT 1.0. -->
  <xsl:template name="member-names">
    <xsl:param name="refs"/>
    <xsl:variable name="clean" select="normalize-space($refs)"/>
    <xsl:if test="string-length($clean) &gt; 0">
      <xsl:variable name="first" select="substring-before(concat($clean, ' '), ' ')"/>
      <xsl:variable name="remaining" select="substring-after($clean, ' ')"/>
      <xsl:choose><xsl:when test="key('members', $first)"><xsl:value-of select="key('members', $first)/fullName"/></xsl:when><xsl:otherwise><xsl:value-of select="$first"/></xsl:otherwise></xsl:choose>
      <xsl:if test="string-length($remaining) &gt; 0"><xsl:text>, </xsl:text><xsl:call-template name="member-names"><xsl:with-param name="refs" select="$remaining"/></xsl:call-template></xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="session">
    <xsl:variable name="linkedClass" select="key('classes', @classRef)"/>
    <xsl:variable name="linkedRoom" select="key('rooms', @roomRef)"/>
    <xsl:variable name="refs" select="normalize-space(registrations/@memberRefs)"/>
    <xsl:variable name="registrationsCount" select="number(boolean(string-length($refs))) * (string-length($refs) - string-length(translate($refs, ' ', '')) + 1)"/>
    <tr>
      <td><strong><xsl:value-of select="@day"/></strong><span class="table-muted"><xsl:value-of select="startTime"/>–<xsl:value-of select="endTime"/></span></td>
      <td><strong><xsl:value-of select="$linkedClass/className"/></strong><span class="table-muted"><xsl:value-of select="key('trainers', $linkedClass/@trainerRef)/fullName"/></span></td>
      <td><strong><xsl:value-of select="$linkedRoom/roomName"/></strong><span class="table-muted"><xsl:value-of select="$linkedRoom/@type"/></span></td>
      <td><span class="count-badge"><xsl:value-of select="$registrationsCount"/> / <xsl:value-of select="$linkedRoom/capacity"/></span><xsl:choose><xsl:when test="$refs != ''"><span class="table-muted"><xsl:call-template name="member-names"><xsl:with-param name="refs" select="$refs"/></xsl:call-template></span></xsl:when><xsl:otherwise><span class="table-muted">No registered members</span></xsl:otherwise></xsl:choose></td>
      <td><span class="idline"><xsl:value-of select="@id"/></span><xsl:if test="note"><span class="table-muted"><xsl:value-of select="note"/></span></xsl:if></td>
    </tr>
  </xsl:template>

  <xsl:template match="trainer">
    <article class="trainer-card"><div class="trainer-top"><span class="avatar"><xsl:value-of select="substring(fullName, 1, 1)"/></span><span class="tag"><xsl:value-of select="@employment"/></span></div>
      <h3><xsl:value-of select="fullName"/></h3><p class="accent-text"><xsl:value-of select="specialty"/></p>
      <p><a href="mailto:{email}"><xsl:value-of select="email"/></a></p><xsl:if test="phone"><p><xsl:value-of select="phone"/></p></xsl:if>
      <div class="equipment"><strong>Certifications</strong><xsl:choose><xsl:when test="certification"><ul><xsl:for-each select="certification"><li><xsl:value-of select="."/></li></xsl:for-each></ul></xsl:when><xsl:otherwise><p>No certifications listed.</p></xsl:otherwise></xsl:choose></div>
      <p class="idline">Trainer ID: <xsl:value-of select="@id"/></p>
    </article>
  </xsl:template>

  <xsl:template match="member">
    <tr><td><strong><xsl:value-of select="fullName"/></strong><span class="table-muted idline"><xsl:value-of select="@id"/></span></td>
      <td><strong><xsl:value-of select="age"/> years</strong><span class="table-muted">Joined <xsl:value-of select="joinedOn"/></span></td>
      <td><strong><xsl:value-of select="key('plans', @planRef)/planName"/></strong><span class="table-muted"><xsl:value-of select="@planRef"/></span></td>
      <td><span class="status status-{@status}"><xsl:value-of select="@status"/></span></td>
      <td><a href="mailto:{email}"><xsl:value-of select="email"/></a><xsl:if test="phone"><span class="table-muted"><xsl:value-of select="phone"/></span></xsl:if></td>
      <td><xsl:choose><xsl:when test="emergencyContact"><strong><xsl:value-of select="emergencyContact/fullName"/></strong><span class="table-muted"><xsl:value-of select="emergencyContact/phone | emergencyContact/email"/></span></xsl:when><xsl:otherwise><span class="table-muted">Not provided</span></xsl:otherwise></xsl:choose></td>
    </tr>
  </xsl:template>

  <xsl:template match="room">
    <article class="room-card"><div class="card-top"><span class="tag"><xsl:value-of select="@type"/></span><span class="idline"><xsl:value-of select="@id"/></span></div>
      <h3><xsl:value-of select="roomName"/></h3><p class="room-capacity"><xsl:value-of select="capacity"/><span> person capacity</span></p>
      <div class="equipment"><strong>Amenities</strong><xsl:choose><xsl:when test="amenities/amenity"><ul><xsl:for-each select="amenities/amenity"><li><xsl:value-of select="."/></li></xsl:for-each></ul></xsl:when><xsl:otherwise><p>No additional amenities listed.</p></xsl:otherwise></xsl:choose></div>
    </article>
  </xsl:template>
</xsl:stylesheet>
